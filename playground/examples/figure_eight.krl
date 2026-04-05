-- SPDX-License-Identifier: PMPL-1.0-or-later
-- KRL example: figure-eight knot

let fig8 = close (sigma 1 ; sigma_inv 2 ; sigma 1 ; sigma_inv 2)

-- Equivalence query
equivalent? fig8 (mirror fig8)
