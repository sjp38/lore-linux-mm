Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A3D296B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 03:44:43 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n967ifdF025808
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Oct 2009 16:44:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C84D745DE4F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 16:44:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AD44845DE4E
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 16:44:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 93E871DB8038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 16:44:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DB531DB8047
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 16:44:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc patch 3/3] mm: munlock COW pages on truncation unmap
In-Reply-To: <20091005193200.GA13040@cmpxchg.org>
References: <2f11576a0910030656l73c9811w18e0f224fb3d98af@mail.gmail.com> <20091005193200.GA13040@cmpxchg.org>
Message-Id: <20091006163748.1263.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Oct 2009 16:44:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> On Sat, Oct 03, 2009 at 10:56:55PM +0900, KOSAKI Motohiro wrote:
> > >> Umm..
> > >> I haven't understand this.
> > >>
> > >> (1) unmap_mapping_range() is called twice.
> > >>
> > >>       unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> > >>       truncate_inode_pages(mapping, new);
> > >>       unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> > >>
> > >> (2) PG_mlock is turned on from mlock() and vmscan.
> > >> (3) vmscan grab anon_vma, but mlock don't grab anon_vma.
> > >
> > > You are right, I was so focused on the LRU side that I missed an
> > > obvious window here: an _explicit_ mlock can still happen between the
> > > PG_mlocked clearing section and releasing the page.
> 
> Okay, so what are the opinions on this?  Would you consider my patches
> to fix the most likely issues?  Dropping them in favor of looking for
> a complete fix?  Revert the warning on freeing PG_mlocked pages?

Honestly, I don't have any good idea. but luckly, we have enough time.
the false-positve warning is not so big problem. then, I prefer looking for
complete solusion.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
