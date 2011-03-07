Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2514C8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 01:13:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1425E3EE0C1
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:13:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA56245DE6A
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:13:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C357D45DE67
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:13:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1CB41DB803A
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:13:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B0A1E38007
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:13:41 +0900 (JST)
Date: Mon, 7 Mar 2011 15:07:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove inline from scan_swap_map
Message-Id: <20110307150721.16ff00e8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
References: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org

On Sat,  5 Mar 2011 15:49:16 -0300
Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> scan_swap_map is a large function (224 lines), with several loops and a
> complex control flow involving several gotos.
> 
> Given all that, it is a bit silly that is is marked as inline. The
> compiler agrees with me: on a x86-64 compile, it did not inline the
> function.
> 
> Remove the "inline" and let the compiler decide instead.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
