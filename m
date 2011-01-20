Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D00138D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 05:19:02 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p0KAFGjJ029145
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 21:15:16 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KAImKT2408626
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 21:18:48 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KAImo2020003
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 21:18:48 +1100
Date: Thu, 20 Jan 2011 15:48:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-ID: <20110120101844.GI2897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110117191359.GI2212@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110117191359.GI2212@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>
List-ID: <linux-mm.kvack.org>

* Johannes Weiner <hannes@cmpxchg.org> [2011-01-17 20:14:00]:

> Hello,
> 
> on the MM summit, I would like to talk about the current state of
> memory control groups, the features and extensions that are currently
> being developed for it, and what their status is.
> 
> I am especially interested in talking about the current runtime memory
> overhead memcg comes with (1% of ram) and what we can do to shrink it.
> 
> In comparison to how efficiently struct page is packed, and given that
> distro kernels come with memcg enabled per default, I think we should
> put a bit more thought into how struct page_cgroup (which exists for
> every page in the system as well) is organized.
> 
> I have a patch series that removes the page backpointer from struct
> page_cgroup by storing a node ID (or section ID, depending on whether
> sparsemem is configured) in the free bits of pc->flags.
> 
> I also plan on replacing the pc->mem_cgroup pointer with an ID
> (KAMEZAWA-san has patches for that), and move it to pc->flags too.
> Every flag not used means doubling the amount of possible control
> groups, so I have patches that get rid of some flags currently
> allocated, including PCG_CACHE, PCG_ACCT_LRU, and PCG_MIGRATION.
> 
> [ I meant to send those out much earlier already, but a bug in the
> migration rework was not responding to my yelling 'Marco', and now my
> changes collide horribly with THP, so it will take another rebase. ]
> 
> The per-memcg dirty accounting work e.g. allocates a bunch of new bits
> in pc->flags and I'd like to hash out if this leaves enough room for
> the structure packing I described, or whether we can come up with a
> different way of tracking state.
> 
> Would other people be interested in discussing this?
>

I would definitely be if I am invited to the LSF/MM summit. Even
otherwise we should discuss this over email

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
