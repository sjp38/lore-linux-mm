Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 399396B015C
	for <linux-mm@kvack.org>; Wed, 13 May 2009 21:34:36 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E1Z6HX018543
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 10:35:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DED545DE55
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:35:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 370B645DE54
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:35:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 02F67E08005
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:35:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 993DDE0800C
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:35:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] Low overhead patches for the memory resource controller
In-Reply-To: <20090513153218.GQ13394@balbir.in.ibm.com>
References: <20090513153218.GQ13394@balbir.in.ibm.com>
Message-Id: <20090514103123.9B52.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 10:35:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> Important: Not for inclusion, for discussion only
> 
> I've been experimenting with a version of the patches below. They add
> a PCGF_ROOT flag for tracking pages belonging to the root cgroup and
> disable LRU manipulation for them
> 
> Caveats:
> 
> 1. I've not checked accounting, accounting might be broken
> 2. I've not made the root cgroup as non limitable, we need to disable
> hard limits once we agree to go with this
> 
> 
> Tests
> 
> Quick tests show an improvement with AIM9
> 
>                 mmotm+patch     mmtom-08-may-2009
> AIM9            1338.57         1338.17
> Dbase           18034.16        16021.58
> New Dbase       18482.24        16518.54
> Shared          9935.98         8882.11
> Compute         16619.81        15226.13
> 
> Comments on the approach much appreciated
> 
> Feature: Remove the overhead associated with the root cgroup
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> This patch changes the memory cgroup and removes the overhead associated
> with accounting all pages in the root cgroup. As a side-effect, we can
> no longer set a memory hard limit in the root cgroup.
> 
> A new flag is used to track page_cgroup associated with the root cgroup
> pages.

I think this is right direction path. typical desktop user don't use 
non-root cgroup nor cgroup disabling boot parameter.
this patch increase their user experience.

I hope you fix rest technical issue.

thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
