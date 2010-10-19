Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 565336B00D8
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 01:41:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J5euLg006260
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 14:40:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 98E5A45DE51
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:40:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 77F5F45DE4F
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:40:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55A9DE38001
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:40:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16BB31DB803B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:40:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 03/35] mm: implement per-zone shrinker
In-Reply-To: <20101019053320.GA7470@amd>
References: <20101019134345.A1E9.A69D9226@jp.fujitsu.com> <20101019053320.GA7470@amd>
Message-Id: <20101019143806.A1F5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 14:40:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> On Tue, Oct 19, 2010 at 01:49:12PM +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > Index: linux-2.6/include/linux/mm.h
> > > ===================================================================
> > > --- linux-2.6.orig/include/linux/mm.h	2010-10-19 14:19:40.000000000 +1100
> > > +++ linux-2.6/include/linux/mm.h	2010-10-19 14:36:48.000000000 +1100
> > > @@ -997,6 +997,10 @@
> > >  /*
> > >   * A callback you can register to apply pressure to ageable caches.
> > >   *
> > > + * 'shrink_zone' is the new shrinker API. It is to be used in preference
> > > + * to 'shrink'. One must point to a shrinker function, the other must
> > > + * be NULL. See 'shrink_slab' for details about the shrink_zone API.
> > 
> ...
> 
> > Now we decided to don't remove old (*shrink)() interface and zone unaware
> > slab users continue to use it. so why do we need global argument?
> > If only zone aware shrinker user (*shrink_zone)(), we can remove it.
> > 
> > Personally I think we should remove it because a removing makes a clear
> > message that all shrinker need to implement zone awareness eventually.
> 
> I agree, I do want to remove the old API, but it's easier to merge if
> I just start by adding the new API. It is split out from my previous
> patch which does convert all users of the API. When this gets merged, I
> will break those out and send them via respective maintainers, then
> remove the old API when they're all converted upstream.

Ok, I've got. I have no objection this step-by-step development. thanks
quick responce!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
