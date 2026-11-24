//! Original CPU reference fixtures. Not a GPU or title compatibility test.
fn depth_pass(incoming: f32, stored: f32, reversed: bool) -> bool {
    if reversed {
        incoming > stored
    } else {
        incoming < stored
    }
}

fn over(src: [f32; 4], dst: [f32; 4]) -> [f32; 4] {
    // Inputs and output are premultiplied linear RGBA.
    let remain = 1.0 - src[3];
    std::array::from_fn(|i| src[i] + dst[i] * remain)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normal_and_reversed_depth() {
        assert!(depth_pass(0.2, 0.8, false));
        assert!(!depth_pass(0.8, 0.2, false));
        assert!(depth_pass(0.8, 0.2, true));
        assert!(!depth_pass(0.2, 0.8, true));
        assert!(!depth_pass(0.5, 0.5, false));
        assert!(!depth_pass(0.5, 0.5, true));
    }

    #[test]
    fn premultiplied_alpha() {
        let blue = [0.0, 0.0, 1.0, 1.0];
        assert_eq!(over([0.0; 4], blue), blue);
        assert_eq!(over([1.0, 0.0, 0.0, 1.0], blue), [1.0, 0.0, 0.0, 1.0]);
        assert_eq!(over([0.5, 0.0, 0.0, 0.5], blue), [0.5, 0.0, 0.5, 1.0]);
    }
}
