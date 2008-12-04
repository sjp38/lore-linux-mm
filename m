Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB454ZG2025468
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 14:04:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C63945DE63
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:04:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B53C45DE5D
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:04:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F9861DB8040
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:04:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA3301DB803E
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 14:04:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: improve reclaim throuput to bail out patch take2
In-Reply-To: <28c262360812032020k6259b71bx5609626db622a884@mail.gmail.com>
References: <20081204102729.1D5C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <28c262360812032020k6259b71bx5609626db622a884@mail.gmail.com>
Message-Id: <20081204132253.1D68.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 14:04:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Hi

> Hi, Kosaki-san.
> 
> It's a great improvement with only one variable than I expected. :)
> What is your test environment ? (CPU, L1, L2 cache size and so )
> Just out of curiosity.

CPU: ia64x8
L1: 16KB
L2: 512KB
L3: 24MB




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
