Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D32945F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 23:18:30 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3K3IjGF026510
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Apr 2009 12:18:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B22F45DE53
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:18:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B37A45DE51
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:18:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 412E5E1800B
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:18:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DE92FE18005
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:18:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <49EBDADB.4040307@gmail.com>
References: <20090420084533.7f701e16.minchan.kim@barrios-desktop> <49EBDADB.4040307@gmail.com>
Message-Id: <20090420121401.4B60.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Apr 2009 12:18:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I think there two places to put back the gup() pages.
> <1> isolate_page_glable()
> <2> in the shrink_page_list(), before called the try_to_unmap().
> KOSAKI Motohiro 's patch takes effect in the second place.
> I think the first place is better.

It seems don't works it.

Andrea pointed out mmu_notifier issue. kvm pinned various page for
shadow pte.
it is unmapped by mmu_notifier_invalidate_page() in try_to_unmap_one().

Thus, we can only check page_count after mmu_notifier_invalidate_page.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
