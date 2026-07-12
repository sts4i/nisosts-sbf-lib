# nisosts-sbf-lib – Schematron Batch Fix library for NISO STS

This repository contains the Schematron files and XSLT fixes of [sts4i-tools](https://github.com/sts4i/sts4i-tools/tree/master/schematron). It will add XProc fixes (for example, for renaming image files in a ZIP archive). 

The Schematron Batch Fix mechanism that resides in sts4i-tools is currently being re-implemented in XProc 3. While the sts4i-tools SBF library is narrowly focused on NISO STS (not in general, but regarding the [`target-niso-version`](https://github.com/sts4i/sts4i-tools/blob/master/validate/validate.xpl#L37) option and the resulting DOCTYPE that it attaches to the XML output), the new implementation will be agnostic with respect to the target XML vocabulary. The new location for the generalized SBF library is at [transpect/sbf](https://github.com/transpect/sbf/). A Balisage paper that describes the re-implementation will follow soon.
