Subject: Significant Memory Reduction Using Huge Page Patch on Database Workload
Message-ID: <OF3B2D710E.252B485F-ON85256C5D.00500150@pok.ibm.com>
From: "Peter Wong" <wpeter@us.ibm.com>
Date: Fri, 25 Oct 2002 11:38:58 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
Cc: Bill Hartner <bhartner@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

     (1) 2.5.43-mm2:
         2.5.43 + Andrew Morton's mm2 patch

     (2) 2.5.43-mm2+huge:
         2.5.43 + Andrew Morton's mm2 patch
                + Bill Irwin's hugetlb patch

     Andrew' mm2 patch can be found at:
http://www.zipworld.com.au/~akpm/linux/patches/2.5/2.5.43/2.5.43-mm2/.

     The objective of this comparison is to measure the impact of
Bill's patch. We used 680 for nr_hugepages, ~2.66 GB for the runs.

----------------------------------------------------------------------
System Information:

   - 8-way 700MHz Pentium III Xeon processors, 2MB L2 Cache
   - 4GB RAM
   - 6 SCSI controllers connected to 120 9.1 GB disks with 10K RPM
----------------------------------------------------------------------

     Based upon the performance metrics and CPU utilization, the two
kernels achieve similar performance. However, memory consumption
by rmap and page tables is reduced significantly by using Bill's
patch.


                               2.5.43-mm2         2.5.43-mm2+huge
     ==============================================================
     pte_chain  (max) (MB)        4.3                182.4


     PageTables (max) (MB)        9.5                153.7


     In total, we save ~322 MB in the low memory area.

Regards,
Partha and Peter

Partha Narayanan and Peter Wai Yee Wong
IBM LTC Performance Team
email: wpeter@us.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
