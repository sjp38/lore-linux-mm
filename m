Subject: Examining the Performance and Cost of Revesemaps on 2.5.26 Under Heavy DB
 Workload
Message-ID: <OF6165D951.694A9B41-ON85256C36.00684F02@pok.ibm.com>
From: "Peter Wong" <wpeter@us.ibm.com>
Date: Tue, 17 Sep 2002 13:30:42 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lse-tech@lists.sourceforge.net
Cc: riel@nl.linux.org, akpm@zip.com.au, mjbligh@us.ibm.com, wli@holomorphy.com, dmccr@us.ibm.comgh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

     I measured a decision support workload using two 2.5.26-based
kernels, one of which does NOT have the rmap rollup patch while the
other HAS. The database size is 100GB. The 2.5.26 rmap rollup patch
was created by Dave McCracken.

     Based upon the throughput rate and CPU utilization, the two
kernels achieve similar performance.

     Based upon /proc/meminfo, the maximum reversemap size is
22,817,885.

     Based upon /proc/slabinfo, the maximum number of active pte_chain
objects is 3,411,018 with 32 bytes each. It consumes about 104 MB. The
maximum number of slabs allocated for pte_chains is 30,186 with 4KB
each, corresponding to about 118 MB. Similar memory consumption for
rmaps is observed while running the same workload and using Andrew
Morton's mm2 patch under 2.5.32. Andrew's patch can be found at
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.32/2.5.32-mm2/.

     Note that since readv is not available on 2.5.26,  the runs above
used "read" instead of "readv".

     My previous note (Sept. 10, 2002) indicated that the memory
consumption for rmaps under 2.5.32 using "readv" is about 223 MB. And
"readv" is the preferred method for this workload. The difference of
memory consumption by using read (118 MB) and readv (223 MB) is likely
due to the different I/O algorithms used by the DBMS. When there are
multiple instances of this workload running concurrently, the amount
of memory allocated to rmaps is even more significant. More data will
be provided later.

----------------------------------------------------------------------
System Information:

   - 8-way 700MHz Pentium III Xeon processors, 2MB L2 Cache
   - 4GB RAM
   - 6 SCSI controllers connected to 120 9.1 GB disks with 10K RPM
----------------------------------------------------------------------

Regards,
Peter

Peter Wai Yee Wong
IBM Linux Technology Center, Performance Analysis
email: wpeter@us.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
