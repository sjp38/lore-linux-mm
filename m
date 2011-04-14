Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 240BE900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:03:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6B6C83EE0BB
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:03:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 50B5B45DE5D
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:03:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D23445DE60
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:03:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 154C1E08001
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:03:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CBDA1E08006
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:03:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] oom: replace PF_OOM_ORIGIN with toggling oom_score_adj
In-Reply-To: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com>
Message-Id: <20110414090310.07FF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Apr 2011 09:03:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

> There's a kernel-wide shortage of per-process flags, so it's always 
> helpful to trim one when possible without incurring a significant 
> penalty.  It's even more important when you're planning on adding a per-
> process flag yourself, which I plan to do shortly for transparent 
> hugepages.
> 
> PF_OOM_ORIGIN is used by ksm and swapoff to prefer current since it has a 
> tendency to allocate large amounts of memory and should be preferred for 
> killing over other tasks.  We'd rather immediately kill the task making 
> the errant syscall rather than penalizing an innocent task.
> 
> This patch removes PF_OOM_ORIGIN since its behavior is equivalent to 
> setting the process's oom_score_adj to OOM_SCORE_ADJ_MIN.

s/OOM_SCORE_ADJ_MIN/OOM_SCORE_ADJ_MAX/ ?

OOM_SCORE_ADJ_MIN == -1000. then,
	points += OOM_SCORE_ADJ_MIN
makes very small value (usually 1).




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
