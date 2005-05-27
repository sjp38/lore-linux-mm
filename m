Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4REG8bV002989
	for <linux-mm@kvack.org>; Fri, 27 May 2005 10:16:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4REG7X8138466
	for <linux-mm@kvack.org>; Fri, 27 May 2005 10:16:07 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4REG7t4004713
	for <linux-mm@kvack.org>; Fri, 27 May 2005 10:16:07 -0400
Subject: Re: [ckrm-tech] Virtual NUMA machine and CKRM
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050527.221613.78716667.taka@valinux.co.jp>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
	 <20050527.221613.78716667.taka@valinux.co.jp>
Content-Type: text/plain
Date: Fri, 27 May 2005 07:15:58 -0700
Message-Id: <1117203358.18725.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: "Chandra S. Seetharaman [imap]" <sekharan@us.ibm.com>, ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-05-27 at 22:16 +0900, Hirokazu Takahashi wrote:
> Why don't you implement CKRM memory controller as virtual NUMA
> node.
> 
> I think what you want do is almost what NUMA code does, which
> restricts resources to use. If you define virtual NUMA node with
> some memory and some virtual CPUs, you can just assign target jobs
> to them.
> 
> What do you think of my idea?

First of all, NUMA nodes don't have any balancing done on them, so I
don't think they're an appropriate structure.  But, NUMA nodes *do*
contain zones, which are a slightly more appropriate structure.

One thing I pointed out when he first posted this code was that a lot of
the accounting gets shifted from the 'struct zone' to the ckrm class.
It was appropriate to have a set of macros to set up and perform this
indirection.

However, a 'struct zone' currently has more than one job.  It collects
"like" pages together, it provides accounting for those pages, and it
represents a contiguous area of memory.

If you could collect just the accounting pieces out of 'struct zone',
perhaps those could be used by both ckrm classes, and the old 'struct
zone'.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
