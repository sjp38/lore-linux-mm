Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EF2D46B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 00:43:19 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7G4emiZ012265
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 14:40:48 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7G4hGal455156
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 14:43:16 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7G4hFFC013220
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 14:43:16 +1000
Date: Sun, 16 Aug 2009 10:13:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090816044311.GQ5087@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com> <20090806130631.GB6162@localhost> <4A7AD79E.4020604@redhat.com> <20090816032822.GB6888@localhost> <4A878377.70502@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4A878377.70502@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Rik van Riel <riel@redhat.com> [2009-08-15 23:56:39]:

> Wu Fengguang wrote:
>
>> Right, but I meant busty page allocations and accesses on them, which
>> can make a large continuous segment of referenced pages in LRU list,
>> say 50MB.  They may or may not be valuable as a whole, however a local
>> algorithm may keep the first 4MB and drop the remaining 46MB.
>
> I wonder if the problem is that we simply do not keep a large
> enough inactive list in Jeff's test.  If we do not, pages do
> not have a chance to be referenced again before the reclaim
> code comes in.
>
> The cgroup stats should show how many active anon and inactive
> anon pages there are in the cgroup.
>

Yes, we do show active and inactive anon pages in the mem cgroup
controller in the memory.stat file.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
