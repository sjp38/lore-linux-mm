Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBEJXnet256310
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 14:33:49 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBEJXnkx214838
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 12:33:49 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBEJXmLG022264
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 12:33:49 -0700
Subject: Re: Anticipatory prefaulting in the page fault handler V2
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0412131730410.817@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
	 <156610000.1102546207@flay>
	 <Pine.LNX.4.58.0412091130160.796@schroedinger.engr.sgi.com>
	 <200412132330.23893.amgta@yacht.ocn.ne.jp>
	 <Pine.LNX.4.58.0412130905140.360@schroedinger.engr.sgi.com>
	 <8880000.1102976179@flay>
	 <Pine.LNX.4.58.0412131730410.817@schroedinger.engr.sgi.com>
Content-Type: text/plain
Message-Id: <1103052678.28318.446.camel@localhost.localdomain>
Mime-Version: 1.0
Date: Tue, 14 Dec 2004 13:31:19 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Akinobu Mita <amgta@yacht.ocn.ne.jp>, nickpiggin@yahoo.com.au, Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Just to add another data point:  This works on my 4-way ppc64 (Power4)
box.  I am seeing no degradation when running this on kernbench (which
is expected).  For the curious, here are the results:

Kernbench results with anon-prefault:
349.86user 49.64system 1:57.85elapsed 338%CPU (0avgtext+0avgdata 0maxresident)k
349.65user 49.81system 1:58.31elapsed 337%CPU (0avgtext+0avgdata 0maxresident)k
349.48user 50.00system 1:53.70elapsed 351%CPU (0avgtext+0avgdata 0maxresident)k
349.73user 49.69system 1:57.67elapsed 339%CPU (0avgtext+0avgdata 0maxresident)k
349.75user 49.85system 1:52.71elapsed 354%CPU (0avgtext+0avgdata 0maxresident)k
Elapsed: 116.048s User: 349.694s System: 49.798s CPU: 343.8%

Kernbench results without anon-prefault:
350.86user 52.54system 1:53.45elapsed 355%CPU (0avgtext+0avgdata 0maxresident)k
350.99user 52.36system 1:52.05elapsed 359%CPU (0avgtext+0avgdata 0maxresident)k
350.92user 52.68system 1:54.14elapsed 353%CPU (0avgtext+0avgdata 0maxresident)k
350.98user 52.38system 1:56.17elapsed 347%CPU (0avgtext+0avgdata 0maxresident)k
351.16user 52.31system 1:53.90elapsed 354%CPU (0avgtext+0avgdata 0maxresident)k
Elapsed: 113.942s User: 350.982s System: 52.454s CPU: 353.6%

On Mon, 2004-12-13 at 19:32, Christoph Lameter wrote:
> Changes from V1 to V2:
> - Eliminate duplicate code and reorganize things
> - Use SetReferenced instead of mark_accessed (Hugh Dickins)
> - Fix the problem of the preallocation order increasing out of bounds
> (leading to memory being overwritten with pointers to struct page)
> - Return VM_FAULT_OOM if not able to allocate a single page
> - Tested on i386 and ia64
> - New performance test for low cpu counts (up to 8 so that this does not
> seem to be too exotic)
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
