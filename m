Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B53CC6B00C6
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 19:54:21 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n87NsRwN021350
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 8 Sep 2009 08:54:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E12145DE4F
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:54:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E9BA45DE4E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:54:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E749D1DB8037
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:54:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 918F51DB803E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:54:23 +0900 (JST)
Date: Tue, 8 Sep 2009 08:52:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/8] mm: around get_user_pages flags
Message-Id: <20090908085225.388ce122.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Sep 2009 22:26:51 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> Here's a series of mm mods against current mmotm: mostly cleanup
> of get_user_pages flags, but fixing munlock's OOM, sorting out the
> "FOLL_ANON optimization", and reinstating ZERO_PAGE along the way.
> 
>  fs/binfmt_elf.c         |   42 ++------
>  fs/binfmt_elf_fdpic.c   |   56 ++++-------
>  include/linux/hugetlb.h |    4 
>  include/linux/mm.h      |    4 
>  mm/hugetlb.c            |   62 +++++++------
>  mm/internal.h           |    7 -
>  mm/memory.c             |  180 +++++++++++++++++++++++---------------
>  mm/mlock.c              |   99 ++++++++------------
>  mm/nommu.c              |   22 ++--
>  9 files changed, 235 insertions(+), 241 deletions(-)
> 
> Hugh
> 
Seems much claerer than mine. I'll test.
Thank you very much.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
