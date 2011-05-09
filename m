Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9F26B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 03:49:22 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D5C893EE0BB
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:49:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB14545DE5C
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:49:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DB8545DE5A
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:49:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DDC51DB8048
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:49:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 498691DB8043
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:49:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] mm: proc: move show_numa_map() to fs/proc/task_mmu.c
In-Reply-To: <1303947349-3620-7-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca> <1303947349-3620-7-git-send-email-wilsons@start.ca>
Message-Id: <20110509165102.1663.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 16:49:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Moving show_numa_map() from mempolicy.c to task_mmu.c solves several
> issues.
> 
>   - Having the show() operation "miles away" from the corresponding
>     seq_file iteration operations is a maintenance burden.
> 
>   - The need to export ad hoc info like struct proc_maps_private is
>     eliminated.
> 
>   - The implementation of show_numa_map() can be improved in a simple
>     manner by cooperating with the other seq_file operations (start,
>     stop, etc) -- something that would be messy to do without this
>     change.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>
> ---
>  fs/proc/task_mmu.c |  170 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>  mm/mempolicy.c     |  168 ---------------------------------------------------
>  2 files changed, 168 insertions(+), 170 deletions(-)

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
