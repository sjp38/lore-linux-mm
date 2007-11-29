Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lATEhZXG017657
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 09:43:35 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lATEhVSq110488
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 09:43:35 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lATEhUU1016204
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 09:43:31 -0500
Message-ID: <474ED005.7060300@linux.vnet.ibm.com>
Date: Thu, 29 Nov 2007 20:13:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: What can we do to get ready for memory controller merge in 2.6.25
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@sw.ru>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, "Martin J. Bligh" <mbligh@google.com>, Andy Whitcroft <andyw@uk.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

They say better strike when the iron is hot.

Since we have so many people discussing the memory controller, I would
like to access the readiness of the memory controller for mainline
merge. Given that we have some time until the merge window, I'd like to
set aside some time (from my other work items) to work on the memory
controller, fix review comments and defects.

In the past, we've received several useful comments from Rik Van Riel,
Lee Schermerhorn, Peter Zijlstra, Hugh Dickins, Nick Piggin, Paul Menage
and code contributions and bug fixes from Hugh Dickins, Pavel Emelianov,
Lee Schermerhorn, YAMAMOTO-San, Andrew Morton and KAMEZAWA-San. I
apologize if I missed out any other names or contributions

At the VM-Summit we decided to try the current double LRU approach for
memory control. At this juncture in the space-time continuum, I seek
your support, feedback, comments and help to move the memory controller

-- 
	Thanks,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
