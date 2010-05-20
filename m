Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B29F6B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 19:23:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4KNNBQ0012785
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 21 May 2010 08:23:11 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FFC445DE4F
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:23:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F74F45DE4E
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:23:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17D23E08002
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:23:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB07AE08001
	for <linux-mm@kvack.org>; Fri, 21 May 2010 08:23:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 4/5] vmscan: remove isolate_pages callback scan control
In-Reply-To: <20100519214217.GC2868@cmpxchg.org>
References: <20100513122717.215E.A69D9226@jp.fujitsu.com> <20100519214217.GC2868@cmpxchg.org>
Message-Id: <20100521081426.1E2E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 21 May 2010 08:23:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > There are the same logic in shrink_active/inactive_list.
> > Can we make wrapper function? It probably improve code readability.
> 
> They are not completely identical, PGSCAN_DIRECT/PGSCAN_KSWAPD
> accounting is only done in shrink_inactive_list(), so we would need an
> extra branch.  Can we leave it like that for now?

Ah. ok, I see.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
