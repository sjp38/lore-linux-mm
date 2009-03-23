Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 10F036B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 20:26:02 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N1KK7X010973
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 10:20:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BEBF45DE52
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:20:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3243045DE51
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:20:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 146F2E08009
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:20:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C0D431DB8013
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:20:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] fix vmscan to take care of nodemask
In-Reply-To: <20090323101348.07b9c761.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090323100356.e980d266.kamezawa.hiroyu@jp.fujitsu.com> <20090323101348.07b9c761.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090323101632.69E7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 10:20:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, mel@csn.ul.ie, riel@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Kosaki pointed out it's not necessary to initialize struct member value by NULL.
> Remvoed it. 
> 
> Regards,
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> try_to_free_pages() scans zonelist but don't take care of nodemask which is
> given to alloc_pages_nodemask(). This makes try_to_free_pages() less effective.

Yes, ignore nodemask make unnecessary reclaim. it decrease try_to_free_pages()
performance.

Note: currently, try_to_free_pages() stop to process reclaim after 32 pages reclaimed.
then, non intentional node scanning can cause large performance degression.

> 
> Changelog: v1 -> v2
>   - removed unnecessary nodemask=NULL initialization.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

thanks.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
