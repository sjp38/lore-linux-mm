Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 36FDE6B009F
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 20:59:12 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK1x9x7007177
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Dec 2010 10:59:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE77E45DE5B
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C5C9A45DE5A
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B8A85E08006
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83C0CE08002
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:08 +0900 (JST)
Date: Mon, 20 Dec 2010 10:53:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 1/5] drop page reference on remove_from_page_cache
Message-Id: <20101220105322.3b0dba88.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4bd059fc4f45fba7ed29a9f4325deb4f437d39f3.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<4bd059fc4f45fba7ed29a9f4325deb4f437d39f3.1292604745.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Dec 2010 02:13:36 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Now we add page reference on add_to_page_cache but doesn't drop it
> in remove_from_page_cache. Such asymmetric makes confusing about
> page reference so that caller should notice it and comment why they
> release page reference. It's not good API.
> 
> Long time ago, Hugh tried it[1] but gave up of reason which
> reiser4's drop_page had to unlock the page between removing it from
> page cache and doing the page_cache_release. But now the situation is
> changed. I think at least things in current mainline doesn't have any
> obstacles. The problem is fs or somethings out of mainline.
> If it has done such thing like reiser4, this patch could be a problem.
> 
> Do anyone know the such things? Do we care about things out of mainline?
> 
> Note :
> The comment of remove_from_page_cache make by copy & paste & s/swap/page/
> from delete_from_swap_cache.
> 
> [1] http://lkml.org/lkml/2004/10/24/140
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

I like this.
Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
