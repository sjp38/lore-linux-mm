Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m936mUbb009820
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Oct 2008 15:48:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2665E1B801F
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 15:48:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD2772DC01E
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 15:48:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B95F21DB803A
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 15:48:29 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A0801DB803E
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 15:48:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Reclaim page capture v4
In-Reply-To: <28c262360810011946p443350d3hcb271720892e7b85@mail.gmail.com>
References: <1222864261-22570-1-git-send-email-apw@shadowen.org> <28c262360810011946p443350d3hcb271720892e7b85@mail.gmail.com>
Message-Id: <20081003154616.EF74.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  3 Oct 2008 15:48:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Hi, Andy.
> 
> I tested your patch in my desktop.
> The test is just kernel compile with single thread.
> My system environment is as follows.
> 
> model name	: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
> MemTotal:        2065856 kB
> 
> When I tested vanilla, compile time is as follows.
> 
> 2433.53user 187.96system 42:05.99elapsed 103%CPU (0avgtext+0avgdata
> 0maxresident)k
> 588752inputs+4503408outputs (127major+55456246minor)pagefaults 0swaps
> 
> When I tested your patch, as follows.
> 
> 2489.63user 202.41system 44:47.71elapsed 100%CPU (0avgtext+0avgdata
> 0maxresident)k
> 538608inputs+4503928outputs (130major+55531561minor)pagefaults 0swaps
> 
> Regresstion almost is above 2 minutes.
> Do you think It is a trivial?

Ooops.
this is definitly significant regression.


> I know your patch is good to allocate hugepage.
> But, I think many users don't need it, including embedded system and
> desktop users yet.
> 
> So I suggest you made it enable optionally.

No.
if the patch has this significant regression,
nobody turn on its option.

We should fix that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
