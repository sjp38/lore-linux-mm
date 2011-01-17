Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F322A8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 15:39:41 -0500 (EST)
Date: Mon, 17 Jan 2011 21:39:10 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: hunting an IO hang
Message-ID: <20110117203910.GV9506@random.random>
References: <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
 <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
 <1295229722-sup-6494@think>
 <20110116183000.cc632557.akpm@linux-foundation.org>
 <1295231547-sup-8036@think>
 <20110117051135.GI9506@random.random>
 <1295273312-sup-6780@think>
 <20110117142614.GP9506@random.random>
 <20110117144746.GC1411@barrios-desktop>
 <20110117150954.GD1411@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110117150954.GD1411@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chris Mason <chris.mason@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 12:09:54AM +0900, Minchan Kim wrote:
> And don't we need this patch, either?

I think we need your fix too.

I thought about that but I wasn't sure (I was focusing on Chris's bug
that had no hugetlbfs involvement), but your patch makes it more
obvious. At least that place wouldn't risk to break silently ;). I
guess hugepage migration from memory failure wasn't much tested yet...

Maybe it'd be cleaner to add a putback_lru_huge_pages but I don't mind
because it seems nothing but memory-failure will ever attempt to
migrate an hugepage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
