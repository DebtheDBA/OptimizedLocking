# Optimized Locking: Improving SQL Server Transaction Concurrency

Abstract:
Some aspects of the SQL Server engine have not seen much change for a long time - locking is one such component. Until now. Optimized locking is here and it affects not just the locking mechanisms but the way concurrency is handled.

This session is designed to help us understand how optimized locking works. First we will cover the foundation on which it was built, the version store. Then we’ll dig deep into the two components of optimized locking: Transaction ID (TID) and lock after qualification (LAQ). Finally, we’ll review some best practices when enabled.

By the end of this session, you should have a clear understanding of how it works and why we want to take advantage of this new functionality.


---

Additional Notes:
The demo scripts use the AutoDealershipDemo database created by Andy Yun. This also borrows some data from the AdventureWorks database.
