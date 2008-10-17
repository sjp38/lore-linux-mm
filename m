Received: from mq1.gw.fujitsu.co.jp ([10.0.50.171])
	by fgwnews.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9H5emv6032686
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Oct 2008 14:40:48 +0900
Received: from m3.gw.fujitsu.co.jp (m3.gw.fujitsu.co.jp [10.0.50.73])
        by mq1.gw.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9H5dIDd002375
        for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
        Fri, 17 Oct 2008 14:39:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 079902AC029
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:37:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D233E12C046
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:37:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B1DC01DB803A
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:37:47 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 56CAF1DB8038
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:37:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
In-Reply-To: <200810171321.40725.nickpiggin@yahoo.com.au>
References: <48F77430.80001@redhat.com> <200810171321.40725.nickpiggin@yahoo.com.au>
Message-Id: <20081017143307.FAA9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Oct 2008 14:37:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

Hi Nick,

I don't have any opinion against this patch is good or wrong.
but I have a question.


> Really, filemap_fault should not mark the page as accessed,
> zap_pte_range should mark the page has accessed rather than just
> set referenced, and this patch should not clear referenced.

IIRC, sequential mapping pages are usually touched twice.
 1. page fault (caused by readahead)
 2. memcpy in userland

So, if we only drop accessed bit of the page at page fault, the page end up
having accessed bit by memcpy.

pointless?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
