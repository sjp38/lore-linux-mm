Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B676900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:46:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 421C03EE0B6
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:46:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 265E945DE92
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:46:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D35E45DE90
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:46:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 01BA8E18001
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:46:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C1BB5E08002
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:46:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch v2] oom: replace PF_OOM_ORIGIN with toggling oom_score_adj
In-Reply-To: <alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
References: <20110414090310.07FF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
Message-Id: <20110414094652.080D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Apr 2011 09:46:51 +0900 (JST)
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
> setting the process's oom_score_adj to OOM_SCORE_ADJ_MAX.
> 
> The process's old oom_score_adj is stored and then set to 
> OOM_SCORE_ADJ_MAX during the time it used to have PF_OOM_ORIGIN.  The old 
> value is then reinstated when the process should no longer be considered 
> a high priority for oom killing.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: s/OOM_SCORE_ADJ_MIN/OOM_SCORE_ADJ_MAX/ as pointed out by
>      KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Good patch.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
