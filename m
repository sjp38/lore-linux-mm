Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BBF066B0071
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 04:04:58 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB194orq013799
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Dec 2010 18:04:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BEA5A45DE55
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:04:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A542045DE5F
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:04:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9428EE38005
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:04:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BA28E08005
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:04:50 +0900 (JST)
Date: Wed, 1 Dec 2010 17:59:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] Refactor zone_reclaim
Message-Id: <20101201175911.b761ce81.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101201052218.GK2746@balbir.in.ibm.com>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
	<20101130101520.17475.79978.stgit@localhost6.localdomain6>
	<20101201102329.89b96c54.kamezawa.hiroyu@jp.fujitsu.com>
	<20101201044634.GF2746@balbir.in.ibm.com>
	<20101201052218.GK2746@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010 10:52:18 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Balbir Singh <balbir@linux.vnet.ibm.com> [2010-12-01 10:16:34]:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-12-01 10:23:29]:
> > 
> > > On Tue, 30 Nov 2010 15:45:55 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > Refactor zone_reclaim, move reusable functionality outside
> > > > of zone_reclaim. Make zone_reclaim_unmapped_pages modular
> > > > 
> > > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > Why is this min_mapped_pages based on zone (IOW, per-zone) ?
> > >
> > 
> > Kamezawa-San, this has been the design before the refactoring (it is
> > based on zone_reclaim_mode and reclaim based on top of that).  I am
> > reusing bits of existing technology. The advantage of it being
> > per-zone is that it integrates well with kswapd. 
> >
> 

Sorry, what I wanted to here was:

Why min_mapped_pages per zone ?
Why you don't add "limit_for_unmapped_page_cache_size" for the whole system ?

I guess what you really want is "limit_for_unmapped_page_cache_size".

Then, you have to use this kind of mysterious code.
==
(zone_unmapped_file_pages(zone) >
+			UNMAPPED_PAGE_RATIO * zone->min_unmapped_pages))

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
