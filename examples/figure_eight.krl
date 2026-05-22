-- SPDX-License-Identifier: MPL-2.0
-- KRL example: figure-eight knot (4_1)

-- Alternating crossings on a 2-braid
let fig8 = close (sigma 1 ; sigma_inv 2 ; sigma 1 ; sigma_inv 2) ;

-- The figure-eight is amphichiral: mirror ≡ original
let fig8_mirror = mirror fig8 ;
