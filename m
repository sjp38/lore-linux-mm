Subject: Re: Significant Memory Reduction Using Huge Page Patch on Database Workload
Message-ID: <OFEEF58F46.24F2AC24-ON85256C5D.00658701@pok.ibm.com>
From: "Peter Wong" <wpeter@us.ibm.com>
Date: Fri, 25 Oct 2002 13:38:23 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
Cc: Bill Hartner <bhartner@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

Peter Wong wrote:
>
>     Based upon the performance metrics and CPU utilization, the two
>kernels achieve similar performance. However, memory consumption
>by rmap and page tables is reduced significantly by using Bill's
>patch.
>
>
>                               2.5.43-mm2         2.5.43-mm2+huge
>     ==============================================================
>     pte_chain  (max) (MB)        4.3                182.4
>
>
>     PageTables (max) (MB)        9.5                153.7
>
>
>    In total, we save ~322 MB in the low memory area.

The "2.5.43-mm2" and "2.5.43-mm2+huge" in the header should be switched.

Regards,
Peter

Peter Wai Yee Wong
IBM LTC Performance Team
email: wpeter@us.ibm.com



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
