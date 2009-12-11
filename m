Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B181F6B0044
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:42:45 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBB0gfmo021758
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Dec 2009 09:42:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC68845DE52
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:42:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 86C3045DE51
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:42:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4C5B1DB8044
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:42:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EA3C1DB8041
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:42:38 +0900 (JST)
Date: Fri, 11 Dec 2009 09:39:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC mm][PATCH 4/5] add a lowmem check function
Message-Id: <20091211093938.70214f9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0912101155490.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210170036.dde2c147.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0912101155490.5481@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009 11:59:11 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 10 Dec 2009, KAMEZAWA Hiroyuki wrote:
> 
> > This patch adds an integer lowmem_zone, which is initialized to -1.
> > If zone_idx(zone) <= lowmem_zone, the zone is lowmem.
> 
> There is already a policy_zone in mempolicy.h. lowmem is if the zone
> number is  lower than policy_zone. Can we avoid adding another zone
> limiter?
> 
My previous version (one month ago) does that. In this set, I tried to use
unified approach for all CONFIG_NUMA/HIGHMEM/flat ones.

Hmm, How about adding following kind of patch after this

#define policy_zone (lowmem_zone + 1)

and remove policy_zone ? I think the name of "policy_zone" implies
"this is for mempolicy, NUMA" and don't think good name for generic use.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
