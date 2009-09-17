Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 32A0F6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 20:33:21 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H0XKKY006530
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Sep 2009 09:33:20 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C6D845DE58
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 09:33:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C648745DE52
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 09:33:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E671DB803C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 09:33:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 404E01DB806A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 09:33:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] mm: mlock, hugetlb, zero followups
In-Reply-To: <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
Message-Id: <20090917093227.93C9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Sep 2009 09:33:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Here's a gang of four patches against current mmotm, following
> on from the eight around get_user_pages flags, addressing
> concerns raised on those.  Best slotted in as a group after
> mm-foll-flags-for-gup-flags.patch
> 
>  arch/mips/include/asm/pgtable.h |   14 ++++++++
>  mm/hugetlb.c                    |   16 ++++++---
>  mm/internal.h                   |    3 +
>  mm/memory.c                     |   37 +++++++++++++++-------
>  mm/mlock.c                      |   49 ++++++++++++++++++++++--------
>  mm/page_alloc.c                 |    1 
>  6 files changed, 89 insertions(+), 31 deletions(-)

My stress load found no problem too.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
