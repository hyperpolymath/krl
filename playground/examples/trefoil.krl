-- SPDX-License-Identifier: MPL-2.0
-- KRL example: trefoil as a braid closure

let trefoil = close (sigma 1 ; sigma 1 ; sigma 1)

-- Query by invariant
find where jones = trefoil.jones
