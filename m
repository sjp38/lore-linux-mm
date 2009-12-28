Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D400C60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 22:18:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS3IdK6028639
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Dec 2009 12:18:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AB4CE45DE50
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:18:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88C7745DE4F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:18:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7AD81DB803F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:18:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C11D1DB8037
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:18:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page in LRU list.
In-Reply-To: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
Message-Id: <20091228121758.A67E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Dec 2009 12:18:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> 
> VM doesn't add zero page to LRU list. 
> It means zero page's churning in LRU list is pointless. 
> 
> As a matter of fact, zero page can't be promoted by mark_page_accessed
> since it doesn't have PG_lru. 
> 
> This patch prevent unecessary mark_page_accessed call of zero page 
> alghouth caller want FOLL_TOUCH. 
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
