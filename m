Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9451D6B00A2
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 20:59:48 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK1xjZf012878
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Dec 2010 10:59:46 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BEA6E45DE62
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A5B7945DE56
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9614CE38005
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A988E38001
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 10:59:45 +0900 (JST)
Date: Mon, 20 Dec 2010 10:54:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 2/5] fuse: Remove unnecessary page release
Message-Id: <20101220105400.8605db51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <16cfab4a6cb77f47f9a632a774d8bd04b4fe9ff2.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<16cfab4a6cb77f47f9a632a774d8bd04b4fe9ff2.1292604745.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sat, 18 Dec 2010 02:13:37 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> This patch series changes remove_from_page_cache's page ref counting
> rule. page cache ref count is decreased in remove_from_page_cache.
> So we don't need call again in caller context.
> 
> Cc: Miklos Szeredi <miklos@szeredi.hu>
> Cc: fuse-devel@lists.sourceforge.net
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
