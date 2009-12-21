Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9512F6B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 00:34:49 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL5YloD013943
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 14:34:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B8FE245DE70
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 14:34:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66AB745DE7C
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 14:34:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1851A1DB804C
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 14:34:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C59DB1DB8043
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 14:34:45 +0900 (JST)
Date: Mon, 21 Dec 2009 14:31:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm : kill combined_idx
Message-Id: <20091221143139.7088a8d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1261366347-19232-1-git-send-email-shijie8@gmail.com>
References: <1261366347-19232-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 11:32:27 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> In more then half of all the cases, `page' is head of the buddy pair
> {page, buddy} in __free_one_page. That is because the allocation logic
> always picks the head of a chunk, and puts the rest back to the buddy system.
> 
> So calculating the combined page is not needed but waste some cycles in
> more then half of all the cases.Just do the calculation when `page' is
> bigger then the `buddy'.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Hmm...As far as I remember, this code design was for avoiding "if".
Is this compare+jump is better than add+xor ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
