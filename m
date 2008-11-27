Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mARB8VS5004791
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 27 Nov 2008 20:08:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D778645DE55
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:08:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B500345DE52
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:08:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 63FD11DB8045
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:08:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D5AD1DB8038
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:08:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
In-Reply-To: <1227780007.4454.1344.camel@twins>
References: <492E6849.6090205@google.com> <1227780007.4454.1344.camel@twins>
Message-Id: <20081127200501.3CF9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 27 Nov 2008 20:08:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, "H. Peter Anvin" <hpa@zytor.com>, edwintorok@gmail.com
List-ID: <linux-mm.kvack.org>

> Furthermore, /proc code usually isn't written with performance in mind,
> so its usually simple and robust code. Adding it to a 'hot'-path like
> you're doing doesn't seem advisable.
> 
> Also, releasing and re-acquiring mmap_sem can significantly add to the
> cacheline bouncing that thing already has.

Interesting.

I tryed to demonstration /proc slowness.

1. make many process
	$ nice ./hackbench 120 process 10000

2. read /proc
	$ time ps -ef

	0.16s user 0.57s system 1% cpu 46.859 total


HAHAHA!
That is really slow over my expected.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
