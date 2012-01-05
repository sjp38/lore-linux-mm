Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id D5EB46B005C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 01:04:35 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 553C23EE0BD
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:04:34 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3507C45DE5C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:04:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14FBD45DE55
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:04:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 05C6C1DB804E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:04:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD79B1DB8049
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:04:33 +0900 (JST)
Date: Thu, 5 Jan 2012 15:03:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm: test PageSwapBacked in lumpy reclaim
Message-Id: <20120105150322.38d71475.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112282033260.1362@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
	<alpine.LSU.2.00.1112282033260.1362@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org

On Wed, 28 Dec 2011 20:35:13 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Lumpy reclaim does well to stop at a PageAnon when there's no swap, but
> better is to stop at any PageSwapBacked, which includes shmem/tmpfs too.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
