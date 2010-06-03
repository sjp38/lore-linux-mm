Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0AC5D6B01AC
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 00:48:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o534mBuE011753
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 13:48:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 095F945DE5D
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 13:48:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CCF5445DE51
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 13:48:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF073E08003
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 13:48:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 646781DB8038
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 13:48:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom: remove PF_EXITING check completely
In-Reply-To: <alpine.DEB.2.00.1006021359430.32666@chino.kir.corp.google.com>
References: <20100602155455.GB9622@redhat.com> <alpine.DEB.2.00.1006021359430.32666@chino.kir.corp.google.com>
Message-Id: <20100603120814.7242.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 13:48:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On Wed, 2 Jun 2010, Oleg Nesterov wrote:
> 
> > > Today, I've thought to make some bandaid patches for this issue. but
> > > yes, I've reached the same conclusion.
> > >
> > > If we think multithread and core dump situation, all fixes are just
> > > bandaid. We can't remove deadlock chance completely.
> > >
> > > The deadlock is certenaly worst result, then, minor PF_EXITING optimization
> > > doesn't have so much worth.
> > 
> > Agreed! I was always wondering if it really helps in practice.
> > 
> 
> Nack, this certainly does help in practice, it prevents needlessly killing 
> additional tasks when one is exiting and may free memory.  It's much 
> better to defer killing something temporarily if an eligible task (i.e. 
> one that has a high probability of memory allocations on current's nodes 
> or contributing to its memcg) is exiting.
> 
> We depend on this check specifically for our use of cpusets, so please 
> don't remove it.

Your claim violate our development process. Oleg pointed this check
doesn't only work well, but also can makes deadlock. So, We certinally
need anything fix. then, I'll remove this check completely at 2.6.35
timeframe.

But this doesn't mean we refuse you make better patch at all. I expect
we can merge very soon if you make such patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
