//! Standalone analyzer for original or authorized benchmark timing samples.
//! Input: one positive, finite frame duration (milliseconds) per line.
use std::io::{self, BufRead};

#[derive(Debug, PartialEq)]
struct Stats {
    count: usize,
    mean_ms: f64,
    fps: f64,
    p50_ms: f64,
    p95_ms: f64,
    p99_ms: f64,
}

fn summarize(mut values: Vec<f64>) -> Result<Stats, &'static str> {
    if values.is_empty() || values.iter().any(|v| !v.is_finite() || *v <= 0.0) {
        return Err("expected at least one positive finite duration");
    }
    values.sort_by(f64::total_cmp);
    let count = values.len();
    // Divide before summing to avoid an overflowing raw sum.
    let mean_ms = values.iter().map(|v| v / count as f64).sum::<f64>();
    let fps = 1000.0 / mean_ms;
    if !mean_ms.is_finite() || !fps.is_finite() || mean_ms <= 0.0 {
        return Err("sample magnitude out of range");
    }
    let percentile = |p: f64| values[((p * count as f64).ceil() as usize).clamp(1, count) - 1];
    Ok(Stats {
        count,
        mean_ms,
        fps,
        p50_ms: percentile(0.50),
        p95_ms: percentile(0.95),
        p99_ms: percentile(0.99),
    })
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut samples = Vec::new();
    for line in io::stdin().lock().lines() {
        let line = line?;
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        samples.push(line.parse::<f64>()?);
    }
    let s = summarize(samples)?;
    println!(
        "{{\"count\":{},\"mean_ms\":{},\"fps\":{},\"p50_ms\":{},\"p95_ms\":{},\"p99_ms\":{}}}",
        s.count, s.mean_ms, s.fps, s.p50_ms, s.p95_ms, s.p99_ms
    );
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn constant_rate() {
        let s = summarize(vec![20.0; 100]).unwrap();
        assert!((s.fps - 50.0).abs() < 1e-9);
        assert_eq!(s.p99_ms, 20.0);
    }

    #[test]
    fn nearest_rank_tail() {
        let s = summarize((1..=100).rev().map(f64::from).collect()).unwrap();
        assert_eq!((s.p50_ms, s.p95_ms, s.p99_ms), (50.0, 95.0, 99.0));
        assert!((s.mean_ms - 50.5).abs() < 1e-9);
    }

    #[test]
    fn rejects_invalid_data() {
        for samples in [vec![], vec![0.0], vec![-1.0], vec![f64::NAN], vec![f64::INFINITY]] {
            assert!(summarize(samples).is_err());
        }
    }
}
