Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C08506B00A6
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 21:00:55 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK20rvC008426
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Dec 2010 11:00:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48EC545DE54
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:00:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32B3245DE56
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:00:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 24568E38007
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:00:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E5A23E38001
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:00:52 +0900 (JST)
Date: Mon, 20 Dec 2010 10:55:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 4/5] swap: Remove unnecessary page release
Message-Id: <20101220105507.cb7ebb88.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <7b8f65cb0e08556bdb48c459cb1f72500f6aa61d.1292604746.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<7b8f65cb0e08556bdb48c459cb1f72500f6aa61d.1292604746.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Dec 2010 02:13:39 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> This patch series changes remove_from_page_cache's page ref counting
> rule. page cache ref count is decreased in remove_from_page_cache.
> So we don't need call again in caller context.
> 
> Cc:Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
