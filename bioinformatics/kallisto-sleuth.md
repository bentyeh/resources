Let $m$ denote the number of features (e.g., transcripts) and $n$ denote the number of samples.

sleuth object: list
- `filter_bool`: logical vector denoting genes passing filter criteria
- `filter_df`: data.frame with 1 column of target_ids of all targets that passed the filter
- `obs_raw`: `data.frame` concatenating all abundance.tsv kallisto files
  - columns: target_id, length, eff_length, est_counts, tpm
- `obs_norm`: same as `obs_raw` but with `est_counts` and `tpm` scaled by `est_counts_sf` and `tpm_sf`
  -  scaling: for a given sample, all values are divided by the scaling factor for that sample
- `obs_norm_filt`: keeping only filtered genes from `obs_norm`
- `est_counts_sf`: `est_counts` scaling factor for each sample
- `tpm_sf`: `tpm` scaling factor for each sample
- `bs_quants`: list of samples
- `bs_summary`
  - `obs_counts`
  - `obs_tpm`
  - `sigma_q_sq`
  - `sigma_q_sq_tpm`

`sleuth_prep()`
- Filter features by `filter_fun`
  - Applied to `est_counts` of each feature (e.g., transcript)
  - Default filter: `sleuth::basic_filter()`
    - Only include features for which the proportion of samples with at least 5 reads is greater than 47%.
- Between-sample normalization: `norm_fun_counts` and `norm_fun_tpm` for counts and tpm values, respectively
  - Default: `sleuth::norm_factors()`
- Data transformation
  - Default: `sleuth::log_transform()` = $\log(x + 0.5)$
  - ?? Why applied to bs_summary$obs_counts instead of obs_norm?

Questions

- gene_mode (on/off): `sleuth_prep`
- which_var ("obs_counts", "obs_tpm"): `sleuth_fit`
- which_units ("tpm", "est_counts", "scaled_reads_per_base"): `sleuth_to_matrix`

- Is the filter applied only to est_counts or to tpm?