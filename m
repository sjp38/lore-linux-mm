Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EF8056B016B
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 10:25:04 -0400 (EDT)
Date: Tue, 2 Aug 2011 15:24:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kernel BUG at mm/vmscan.c:1114
Message-ID: <20110802142459.GF10436@suse.de>
References: <CAJn8CcE20-co4xNOD8c+0jMeABrc1mjmGzju3xT34QwHHHFsUA@mail.gmail.com>
 <CAJn8CcG-pNbg88+HLB=tRr26_R+A0RxZEWsJQg4iGe4eY2noXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJn8CcG-pNbg88+HLB=tRr26_R+A0RxZEWsJQg4iGe4eY2noXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiaotian Feng <xtfeng@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 02, 2011 at 03:09:57PM +0800, Xiaotian Feng wrote:
> Hi,
>    I'm hitting the kernel BUG at mm/vmscan.c:1114 twice, each time I
> was trying to build my kernel. The photo of crash screen and my config
> is attached. Thanks.
> Regards
> Xiaotian

I am obviously blind because in 3.0, I cannot see what BUG is at
mm/vmscan.c:1114 :(. I see

1109:			/*
1110:			 * If we don't have enough swap space, reclaiming of
1111:			 * anon page which don't already have a swap slot is
1112:			 * pointless.
1113:			 */
1114:			if (nr_swap_pages <= 0 && PageAnon(cursor_page) &&
1115:			    !PageSwapCache(cursor_page))
1116:				break;
1117:
1118:			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
1119:				list_move(&cursor_page->lru, dst);
1120:				mem_cgroup_del_lru(cursor_page);

Is this 3.0 vanilla or are there some other patches applied?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
