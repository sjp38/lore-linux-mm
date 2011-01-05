Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 998266B008A
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 03:52:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CAC8B3EE0BC
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 17:52:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB34045DE55
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 17:52:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9655745DD74
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 17:52:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 858E4E08003
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 17:52:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F768E08001
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 17:52:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/7] Change page reference handling semantic of page cache
In-Reply-To: <cover.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
Message-Id: <20110105175156.B65B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  5 Jan 2011 17:52:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

> The series configuration is following as. 
> 
> [1/7] : This patch introduces new API delete_from_page_cache.
> [2,3,4,5/7] : Change remove_from_page_cache with delete_from_page_cache.
> Intentionally I divide patch per file since someone might have a concern 
> about releasing page reference of delete_from_page_cache in 
> somecase (ex, truncate.c)
> [6/7] : Remove old API so out of fs can meet compile error when build time
> and can notice it.
> [7/7] : Change __remove_from_page_cache with __delete_from_page_cache, too.
> In this time, I made all-in-one patch because it doesn't change old behavior
> so it has no concern. Just clean up patch.

All of them,
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
