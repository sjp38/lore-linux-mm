Subject: Significant Memory Reduction Using Sharepte Patch on Database Workload
Message-ID: <OF889EDB45.3A485EF3-ON85256C5D.004A5547@pok.ibm.com>
From: "Peter Wong" <wpeter@us.ibm.com>
Date: Fri, 25 Oct 2002 09:43:32 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au, dmccr@us.ibm.com, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
Cc: Bill Hartner <bhartner@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

     I used a very heavy database workload to evaluate two kernels:

     (1) 2.5.44-mm2:
         2.5.44 + Andrew Morton's mm2 patch

     (2) 2.5.44-mm2-less-shpte:
         2.5.44 + Andrew Morton's mm2 patch
                - Dave McCracken's shpte-ng.patch

     Andrew' mm2 patch can be found at:
http://www.zipworld.com.au/~akpm/linux/patches/2.5/2.5.44/2.5.44-mm2/.

     Note that Dave's shared pte patch is included in Andrew's mm2
patch. The objective of this comparison is to measure the impact
of Dave's patch.

----------------------------------------------------------------------
System Information:

   - 8-way 700MHz Pentium III Xeon processors, 2MB L2 Cache
   - 4GB RAM
   - 6 SCSI controllers connected to 120 9.1 GB disks with 10K RPM
----------------------------------------------------------------------

     Based upon the performance metrics and CPU utilization, the two
kernels achieve similar performance. However, memory consumption
by rmap and page tables is reduced significantly by using Dave's
patch. Basically, a large number of I/O prefetchers and database
agents can share two small sets of page tables, which in turn
reduce the amount of rmap memory.


                               2.5.44-mm2     2.5.44-mm2-less-shpte
     ==============================================================
     pte_chain  (max) (MB)        1.2                182.3


     PageTables (max) (MB)        5.2                153.0


     In total, we save ~330 MB in the low memory area.

Regards,
Peter

Peter Wai Yee Wong
IBM LTC Performance Team
email: wpeter@us.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
