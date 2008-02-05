Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m15CWNNo010123
	for <linux-mm@kvack.org>; Tue, 5 Feb 2008 23:32:23 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m15CW7CT3858644
	for <linux-mm@kvack.org>; Tue, 5 Feb 2008 23:32:07 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m15CW6x1000934
	for <linux-mm@kvack.org>; Tue, 5 Feb 2008 23:32:07 +1100
Message-ID: <47A856E1.4040703@linux.vnet.ibm.com>
Date: Tue, 05 Feb 2008 18:00:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUG] regression from 2.6.24-rc8-mm1 and 2.6.24-mm1 kernel panic
 while bootup
References: <47A81BC9.5060600@linux.vnet.ibm.com> <20080205002544.264a9484.akpm@linux-foundation.org>
In-Reply-To: <20080205002544.264a9484.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, mingo@elte.hu, tglx@linutronix.de, apw@shadowen.org, randy.dunlap@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 05 Feb 2008 13:48:17 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
>
[snip]

> argh, I'd forgotten about that.  You bisected it down to a clearly-innocent
> patch and none of the mm developers appeared interested.
> 
> Oh well, it'll probably be in mainline tomorrow.  That should get it
> fixed.

We've tracked this down to a problem where the nodeid might be invalid. Kamalesh
is investigating problem. We suspect we are doing a kmalloc_node with an invalid
nodeid.

We see

cpu with no node 2, num_online_nodes 1
cpu with no node 3, num_online_nodes 1

in the bootlog. Kamalesh verified that the problem exists with both slub and slab.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
