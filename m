Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 66B7660021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 00:46:20 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS5kGTf006531
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 14:46:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9154745DE69
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 14:46:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6357745DE66
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 14:46:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B6951DB803C
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 14:46:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62A521DB8041
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 14:46:15 +0900 (JST)
Date: Mon, 28 Dec 2009 14:43:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Fix wrong rss count of smaps
Message-Id: <20091228144302.864f2e97.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228143154.ec0431b5.minchan.kim@barrios-desktop>
References: <20091228134619.92ba28f6.minchan.kim@barrios-desktop>
	<20091228134752.44d13c34.kamezawa.hiroyu@jp.fujitsu.com>
	<20091228143154.ec0431b5.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 14:31:54 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > BTW, how about counting ZERO page in smaps? Ignoring them completely sounds
> > not very good.
> 
> I am not use it is useful. 
> 
> zero page snapshot of ongoing process is useful?
> Doesn't Admin need to know about zero page?
> Let's admins use it well. If we remove zero page again?
> How many are applications use smaps? 
> Did we have a problem without it?
> 
My concern is that hiding indormation which was exported before.
No more than that and no strong demand.


> When I think of it, there are too many qeustions. 
> Most important thing to add new statistics is just need of customer. 
> 
> Frankly speaking, I don't have good scenario of using zero page.
> Do you have any scenario it is valueable?
> 
read before write ? maybe sometimes happens.

For example. current glibc's calloc() avoids memset() if the pages are
dropped by MADVISE (without unmap). 

Before starting zero-page works, I checked "questions" in lkml and
found some reports that some applications start to go OOM after zero-page
removal.

For me, I know one of my customer's application depends on behavior of
zero page (on RHEL5). So, I tried to add again it before RHEL6 because
I think removal of zero-page corrupts compatibility.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
