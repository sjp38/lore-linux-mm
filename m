Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5314F6B00B3
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 01:36:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I5aSaY023368
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Oct 2010 14:36:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 42F6045DE50
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:36:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 146EE45DE52
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:36:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CDF741DB8044
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:36:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74225E18001
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:36:27 +0900 (JST)
Date: Mon, 18 Oct 2010 14:31:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] alloc contig pages with migration.
Message-Id: <20101018143108.4e0e5299.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikt+kq2LHZNSJAN3EQwYALdYtGuOAXfVghN-7oY@mail.gmail.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTingNmxT6ww_VB_K=rjsgR+dHANLnyNkwV1Myvnk@mail.gmail.com>
	<20101018093533.abd4c8ee.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikt+kq2LHZNSJAN3EQwYALdYtGuOAXfVghN-7oY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Oct 2010 14:18:52 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> > + *
> >> > + * Search an area of @size in the physical memory map and checks wheter
> >>
> >> Typo
> >> whether
> >>
> >> > + * we can create a contigous free space. If it seems possible, try to
> >> > + * create contigous space with page migration. If no_search==true, we just try
> >> > + * to allocate [hint, hint+size) range of pages as contigous block.
> >> > + *
> >> > + * Returns a page of the beginning of contiguous block. At failure, NULL
> >> > + * is returned. Each page in the area is set to page_count() = 1. Because
> >>
> >> Why do you mention page_count() = 1?
> >> Do users of this function have to know it?
> >
> > A user can free any page within the range for his purpose.
> 
> I think it's not a good idea if we allow handling of page by page, not
> for page-chunk requested by user.
> By mistake, free_contig_pages could have a trouble to free pages.
> Why do you support the feature?  Do you have any motivation?
> 
No big motivation.

Usual pages are set up by prep_compund_page(page, order), but it is pages smaller
than MAX_ORDER.  Then, I called prep_new_page() one by one.
And I don't think some new prep_xxxx_page() is required.

If you requests, ok, I'll add one.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
