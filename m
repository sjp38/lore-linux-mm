Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9N1fb8O008602
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 23 Oct 2008 10:41:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 754101B801E
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 10:41:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 48F2D2DC015
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 10:41:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 290A11DB803B
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 10:41:37 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D70641DB8037
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 10:41:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 0/3] activate pages in batch
In-Reply-To: <20081022225006.010250557@saeurebad.de>
References: <20081022225006.010250557@saeurebad.de>
Message-Id: <20081023104002.1CEA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 23 Oct 2008 10:41:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Hannes

> Instead of re-acquiring the highly contented LRU lock on every single
> page activation, deploy an extra pagevec to do page activation in
> batch.

Do you have any mesurement result?


> 
> The first patch is just grouping all pagevecs we use into one array
> which makes further refactoring easier.
> 
> The second patch simplifies the interface for flushing a pagevec to
> the proper LRU list.
> 
> And finally, the last patch changes page activation to batch-mode.
> 
> 	Hannes
> 
>  include/linux/pagevec.h |   21 +++-
>  mm/swap.c               |  216 ++++++++++++++++++++++++------------------------
>  2 files changed, 127 insertions(+), 110 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
