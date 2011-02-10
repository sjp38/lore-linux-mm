Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CCB988D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 23:23:48 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 428F03EE0B5
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:23:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2716945DE58
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:23:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EDFD45DE55
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:23:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED076E08002
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:23:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B811CE38001
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:23:45 +0900 (JST)
Date: Thu, 10 Feb 2011 13:16:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Fix out-of-date comments which refers non-existent
 functions
Message-Id: <20110210131644.4c3dc48d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikdBhSWAoP6TDRExSV2rHmWDkEc0foSKvqJt=tx@mail.gmail.com>
References: <1297262537-7425-1-git-send-email-ozaki.ryota@gmail.com>
	<20110210085823.2f99b81c.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikdBhSWAoP6TDRExSV2rHmWDkEc0foSKvqJt=tx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryota Ozaki <ozaki.ryota@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Thu, 10 Feb 2011 12:58:21 +0900
Ryota Ozaki <ozaki.ryota@gmail.com> wrote:

> On Thu, Feb 10, 2011 at 8:58 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, A 9 Feb 2011 23:42:17 +0900
> > Ryota Ozaki <ozaki.ryota@gmail.com> wrote:
> >
> >> From: Ryota Ozaki <ozaki.ryota@gmail.com>
> >>
> >> do_file_page and do_no_page don't exist anymore, but some comments
> >> still refers them. The patch fixes them by replacing them with
> >> existing ones.
> >>
> >> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
> >
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Thanks, Kamezawa-san.
> 
> >
> > It seems there are other ones ;)
> > ==
> > A  A Searched full:do_no_page (Results 1 - 3 of 3) sorted by relevancy
> >
> > A /linux-2.6-git/arch/alpha/include/asm/
> > H A D A  cacheflush.h A  A 66 /* This is used only in do_no_page and do_swap_page. */
> > A /linux-2.6-git/arch/avr32/mm/
> > H A D A  cache.c A  A  A  A  116 * This one is called from do_no_page(), do_swap_page() and install_page().
> > A /linux-2.6-git/mm/
> > H A D A  memory.c A  A  A  A 2121 * and do_anonymous_page and do_no_page can safely check later on).
> > 2319 * do_no_page is protected similarly.
> 
> Nice catch :-) Cloud I assemble all fixes into one patch?
> 
>   ozaki-r
> 

Yes, I think it's allowed. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
