Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E85A88D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 03:43:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 628D43EE0AE
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:43:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A6A945DE5D
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:43:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3003345DE56
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:43:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 227651DB8048
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:43:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E1C751DB8044
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 16:43:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <AANLkTimafdn8wPD7Zu3tK4PLgik=-0MeE62nGxq7ks4N@mail.gmail.com>
References: <20110324162936.CC87.A69D9226@jp.fujitsu.com> <AANLkTimafdn8wPD7Zu3tK4PLgik=-0MeE62nGxq7ks4N@mail.gmail.com>
Message-Id: <20110324164307.CC91.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 24 Mar 2011 16:43:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

> On Thu, Mar 24, 2011 at 4:28 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> For example, In 4G desktop system.
> >> 32M full scanning and fail to reclaim a page.
> >> It's under 1% coverage.
> >
> > ?? I'm sorry. I haven't catch it.
> > Where 32M come from?
> 
> (1<<12) * 4K + (1<<11) + 4K + .. (1 << 0) + 4K in shrink_zones.

(lru-pages>>12) + (lru-pages>>11) + (lru-pages>>10) ... =~ 2 * lru-page 

?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
