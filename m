Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B14CA6B00C8
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 20:00:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8800gs0020732
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Sep 2009 09:00:43 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A57EF45DE7C
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 09:00:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F0F945DE60
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 09:00:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DB401DB803F
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 09:00:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AF7BE18002
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 09:00:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8] mm: around get_user_pages flags
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Message-Id: <20090908090009.0CC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Sep 2009 09:00:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

Great!
I'll start to test this patch series. Thanks Hugh!!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
