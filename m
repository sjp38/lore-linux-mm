Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4VJJuLa010506
	for <linux-mm@kvack.org>; Tue, 31 May 2005 15:19:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4VJJueQ144170
	for <linux-mm@kvack.org>; Tue, 31 May 2005 15:19:56 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4VJJtOO000840
	for <linux-mm@kvack.org>; Tue, 31 May 2005 15:19:55 -0400
Date: Tue, 31 May 2005 12:10:54 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: Virtual NUMA machine and CKRM
Message-ID: <20050531191054.GD29202@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com> <20050527.221613.78716667.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050527.221613.78716667.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 27, 2005 at 10:16:13PM +0900, Hirokazu Takahashi wrote:
> Hi Chandra,
> 
> Why don't you implement CKRM memory controller as virtual NUMA
> node.
> 
> I think what you want do is almost what NUMA code does, which
> restricts resources to use. If you define virtual NUMA node with

Besides mixing virtual/physical, IMHO it will be hairy as the ckrm class
needs to have all the zones that exists in the system(unlike the real NUMA
node), and it will get more complicated when CKRM is deployed in a NUMA
system itself.


> some memory and some virtual CPUs, you can just assign target jobs
> to them.
> 
> What do you think of my idea?
> 
> Thanks,
> Hirokazu Takahashi.
> 
> > I am looking for improvement suggestions
> >         - to not have a field in the page data structure for the mem
> >           controller
> > 	- to make vmscan.c cleaner.

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
