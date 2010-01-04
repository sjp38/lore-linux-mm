Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B99E0600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 22:13:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o043DfPQ011341
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 4 Jan 2010 12:13:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C8172AEA8D
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:13:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D3EF1EF081
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:13:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 47F631DB803A
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:13:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04DEB1DB803C
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:13:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 -mmotm-2009-12-10-17-19] Fix wrong rss count of smaps
In-Reply-To: <20100104102319.b878047d.minchan.kim@barrios-desktop>
References: <20100104102319.b878047d.minchan.kim@barrios-desktop>
Message-Id: <20100104121312.969D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  4 Jan 2010 12:13:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matt Mackall <mpm@selenic.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> 
> Long time ago, We regards zero page as file_rss and
> vm_normal_page didn't return NULL in case of zero page
> 
> But now, we reinstated ZERO_PAGE and vm_normal_page's implementation
> can return NULL in case of zero page.
> 
> Then, RSS and PSS can't be matched in smaps_pte_range.
> This patch fixes it.
> 
> Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Acked-by: Matt Mackall <mpm@selenic.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
