Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 781625F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 23:34:14 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n134WNFx031498
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 15:32:23 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n134YPJw217494
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 15:34:25 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n134Y6HP006855
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 15:34:07 +1100
Date: Tue, 3 Feb 2009 10:04:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-ID: <20090203043404.GK918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202140849.GB918@balbir.in.ibm.com> <20090203102157.9f643965.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090203102157.9f643965.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-03 10:21:57]:

> On Mon, 2 Feb 2009 19:38:49 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-02-02 18:22:40]:
> > 
> > > Hi, All,
> > > 
> > > I found the following patch useful while debugging the memory
> > > controller. It adds additional information if memcg invoked the OOM.
> > > 
> > > Comments, Suggestions?
> > >
> > 
> > 
> > Description: Add RSS and swap to OOM output from memcg
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> 
> > This patch displays memcg values like failcnt, usage and limit
> > when an OOM occurs due to memcg.
> > 
> 
> please use "KB" not bytes in OOM killer information.
> 
> And the most important information is dropped..
> Even if you show information, the most important information that
> "where I am and where we hit limit ?" is not coverred.
> Could you consider some way to show full-path ?
> 
>   OOM-Killer:
>   Task in /memory/xxx/yyy/zzz is killed by
>   Limit of /memory/xxxx
>   RSS Limit :     Usage:     Failcnt....
>   RSS+SWAP Limit: ....
>

Sounds good to me, let me add this information. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
