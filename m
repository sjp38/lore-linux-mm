Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 062536B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 02:00:07 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7G5vZq8009814
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 15:57:35 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7G604Uo418190
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 16:00:04 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7G602L0031452
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 16:00:03 +1000
Date: Sun, 16 Aug 2009 11:29:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090816055957.GS5087@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com> <20090806130631.GB6162@localhost> <4A7AD79E.4020604@redhat.com> <20090816032822.GB6888@localhost> <4A878377.70502@redhat.com> <20090816045522.GA13740@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090816045522.GA13740@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Wu Fengguang <fengguang.wu@intel.com> [2009-08-16 12:55:22]:

> On Sun, Aug 16, 2009 at 11:56:39AM +0800, Rik van Riel wrote:
> > Wu Fengguang wrote:
> > 
> > > Right, but I meant busty page allocations and accesses on them, which
> > > can make a large continuous segment of referenced pages in LRU list,
> > > say 50MB.  They may or may not be valuable as a whole, however a local
> > > algorithm may keep the first 4MB and drop the remaining 46MB.
> > 
> > I wonder if the problem is that we simply do not keep a large
> > enough inactive list in Jeff's test.  If we do not, pages do
> > not have a chance to be referenced again before the reclaim
> > code comes in.
> 
> Exactly, that's the case I call the list FIFO.
> 
> > The cgroup stats should show how many active anon and inactive
> > anon pages there are in the cgroup.
> 
> Jeff, can you have a look at these stats? Thanks!

Another experiment would be to toy with memory.swappiness (although
defaults should work well). Could you compare the in-guest values of
nr_*active* with the cgroup values as seen by the host?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
