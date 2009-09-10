Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B0A96B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 20:33:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8A0X5ff029407
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Sep 2009 09:33:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3259145DE51
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 09:33:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 137F145DE55
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 09:33:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ECBC51DB803C
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 09:33:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 537F51DB8046
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 09:33:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8] mm: around get_user_pages flags
In-Reply-To: <20090908090009.0CC0.A69D9226@jp.fujitsu.com>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <20090908090009.0CC0.A69D9226@jp.fujitsu.com>
Message-Id: <20090910093207.9CC6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Sep 2009 09:33:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Here's a series of mm mods against current mmotm: mostly cleanup
> > of get_user_pages flags, but fixing munlock's OOM, sorting out the
> > "FOLL_ANON optimization", and reinstating ZERO_PAGE along the way.
> > 
> >  fs/binfmt_elf.c         |   42 ++------
> >  fs/binfmt_elf_fdpic.c   |   56 ++++-------
> >  include/linux/hugetlb.h |    4 
> >  include/linux/mm.h      |    4 
> >  mm/hugetlb.c            |   62 +++++++------
> >  mm/internal.h           |    7 -
> >  mm/memory.c             |  180 +++++++++++++++++++++++---------------
> >  mm/mlock.c              |   99 ++++++++------------
> >  mm/nommu.c              |   22 ++--
> >  9 files changed, 235 insertions(+), 241 deletions(-)
> 
> Great!
> I'll start to test this patch series. Thanks Hugh!!

At least, My 24H stress workload test didn't find any problem.
I'll continue testing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
