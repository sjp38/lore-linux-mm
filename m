Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2B89960044A
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 19:08:52 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0405uVS022257
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:05:56 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0404PpT1609822
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:04:25 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0408l91011094
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:08:47 +1100
Date: Mon, 4 Jan 2010 05:37:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-ID: <20100104000752.GC16187@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091229182743.GB12533@balbir.in.ibm.com>
 <20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-04 08:51:08]:

> On Tue, 29 Dec 2009 23:57:43 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Hi, Everyone,
> > 
> > I've been working on heuristics for shared page accounting for the
> > memory cgroup. I've tested the patches by creating multiple cgroups
> > and running programs that share memory and observed the output.
> > 
> > Comments?
> 
> Hmm? Why we have to do this in the kernel ?
>

For several reasons that I can think of

1. With task migration changes coming in, getting consistent data free of races
is going to be hard.
2. The cost of doing it in the kernel is not high, it does not impact
the memcg runtime, it is a request-response sort of cost.
3. The cost in user space is going to be high and the implementation
cumbersome to get right.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
