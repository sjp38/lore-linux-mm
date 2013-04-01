Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id C54B26B0002
	for <linux-mm@kvack.org>; Sun, 31 Mar 2013 21:02:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E18F83EE0C5
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 10:02:20 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C47DF45DE50
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 10:02:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A816945DE4F
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 10:02:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 999C91DB803B
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 10:02:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B3BF1DB803F
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 10:02:20 +0900 (JST)
Message-ID: <5158DC7D.2040607@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 10:01:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] THP: Use explicit memory barrier
References: <1364773535-26264-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1364773535-26264-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

(2013/04/01 8:45), Minchan Kim wrote:
> __do_huge_pmd_anonymous_page depends on page_add_new_anon_rmap's
> spinlock for making sure that clear_huge_page write become visible
> after set set_pmd_at() write.
> 
> But lru_cache_add_lru uses pagevec so it could miss spinlock
> easily so above rule was broken so user may see inconsistent data.
> This patch fixes it with using explict barrier rather than depending
> on lru spinlock.
> 

Hmm...how about do_anonymous_page() ? there are no comments/locks/barriers.
Users can see non-zero value after page fault in theory ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
