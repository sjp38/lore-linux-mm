Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i946qhUI017468 for <linux-mm@kvack.org>; Mon, 4 Oct 2004 15:52:43 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i946qhlr024502 for <linux-mm@kvack.org>; Mon, 4 Oct 2004 15:52:43 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 212C81F723B
	for <linux-mm@kvack.org>; Mon,  4 Oct 2004 15:52:42 +0900 (JST)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B7A5F1F7238
	for <linux-mm@kvack.org>; Mon,  4 Oct 2004 15:52:41 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5100G82SFQHR@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Mon,  4 Oct 2004 15:52:39 +0900 (JST)
Date: Mon, 04 Oct 2004 15:58:11 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
In-reply-to: <20041001182221.GA3191@logos.cnet>
Message-id: <4160F483.3000309@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <20041001182221.GA3191@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, Nick Piggin <piggin@cyberone.com.au>, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

Marcelo Tosatti wrote:

> +int can_move_page(struct page *page) 
> +{
   <snip>
> +	if (page_count(page) == 0)
> +		return 1;

I think there are 3 cases when page_count(page) == 0.

1. a page is free and in the buddy allocator.
2. a page is free and in per-cpu-pages list.
3. a page is in pagevec .

I think only case 1 pages meet your requirements.

I used PG_private flag for distinguishing case 1 from 2 and 3
in my no-bitmap buddy allocator posted before.
I added PG_private flag to a page which is in buddy allocator's free_list.

Regards

-- Kame
<kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
