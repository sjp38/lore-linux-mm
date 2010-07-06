Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C03226B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 02:02:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6662Xdl025085
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Jul 2010 15:02:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7130245DE4F
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:02:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D52945DE50
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:02:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F2F1EF8005
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:02:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C3258E38001
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:02:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
In-Reply-To: <AANLkTimk6SwmljTWpIgp_OI_eLP6w8BCWKf-VRUFQ65H@mail.gmail.com>
References: <20100706093529.CCD1.A69D9226@jp.fujitsu.com> <AANLkTimk6SwmljTWpIgp_OI_eLP6w8BCWKf-VRUFQ65H@mail.gmail.com>
Message-Id: <20100706150030.CCFA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  6 Jul 2010 15:02:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jul 6, 2010 at 9:36 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hello,
> >
> >> Ok, that's reasonable as I'm still working on that patch. For example, the
> >> patch disabled anonymous page writeback which is unnecessary as the stack
> >> usage for anon writeback is less than file writeback.
> >
> > How do we examine swap-on-file?
> 
> bool is_swap_on_file(struct page *page)
> {
>     struct swap_info_struct *p;
>     swp_entry_entry entry;
>     entry.val = page_private(page);
>     p = swap_info_get(entry);
>     return !(p->flags & SWP_BLKDEV)
> }

Well, do you suggested we traverse all pages in lru _before_
starting vmscan?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
