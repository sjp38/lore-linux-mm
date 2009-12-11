Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 08D536B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:36:19 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBB0aHwh010728
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Dec 2009 09:36:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F29A45DE4F
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:36:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E42B545DE4E
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:36:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C92401DB8037
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:36:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 801EF1DB8038
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:36:16 +0900 (JST)
Date: Fri, 11 Dec 2009 09:33:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC mm][PATCH 3/5] counting swap ents per mm
Message-Id: <20091211093314.c44527cd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0912101153130.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210165911.97850977.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0912101153130.5481@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009 11:55:25 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 10 Dec 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Index: mmotm-2.6.32-Dec8/mm/rmap.c
> > ===================================================================
> > --- mmotm-2.6.32-Dec8.orig/mm/rmap.c
> > +++ mmotm-2.6.32-Dec8/mm/rmap.c
> > @@ -814,7 +814,7 @@ int try_to_unmap_one(struct page *page,
> >  	update_hiwater_rss(mm);
> >
> >  	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> > -		if (PageAnon(page))
> > +		if (PageAnon(page)) /* Not increments swapents counter */
> >  			dec_mm_counter(mm, MM_ANONPAGES);
> 
> Remove comment. Its not helping.
> 
ok.

> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

Thank you,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
