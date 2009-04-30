Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 522686B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 20:39:05 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U0deIO010874
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 30 Apr 2009 09:39:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16E8145DE4F
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:39:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E943B45DE4E
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:39:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C9CD51DB803B
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:39:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 887141DB8037
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:39:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v3)
In-Reply-To: <20090429131436.640f09ab@cuia.bos.redhat.com>
References: <2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com> <20090429131436.640f09ab@cuia.bos.redhat.com>
Message-Id: <20090430093733.D20C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 30 Apr 2009 09:39:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> When the file LRU lists are dominated by streaming IO pages,
> evict those pages first, before considering evicting other
> pages.
> 
> This should be safe from deadlocks or performance problems
> because only three things can happen to an inactive file page:
> 1) referenced twice and promoted to the active list
> 2) evicted by the pageout code
> 3) under IO, after which it will get evicted or promoted
> 
> The pages freed in this way can either be reused for streaming
> IO, or allocated for something else. If the pages are used for
> streaming IO, this pageout pattern continues. Otherwise, we will
> fall back to the normal pageout pattern.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> 
> ---
> On Thu, 30 Apr 2009 01:07:51 +0900
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > we handle active_anon vs inactive_anon ratio by shrink_list().
> > Why do you insert this logic insert shrink_zone() ?
> 
> Kosaki, this implementation mirrors the anon side of things precisely.
> Does this look good?
> 
> Elladan, this patch should work just like the second version. Please
> let me know how it works for you.

Looks good to me. thanks.
but I don't hit Rik's explained issue, I hope Elladan report his test result.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
