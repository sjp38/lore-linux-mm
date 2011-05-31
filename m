Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 003816B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 01:55:36 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2318830pzk.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 22:55:35 -0700 (PDT)
Date: Tue, 31 May 2011 14:55:28 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
Message-ID: <20110531055528.GB1519@barrios-laptop>
References: <1306774744.4061.5.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306774744.4061.5.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, May 30, 2011 at 10:59:04PM +0600, Rakib Mullick wrote:
> commit 468fd62ed9 (vmstats: add cond_resched() to refresh_cpu_vm_stats()) added cond_resched() in refresh_cpu_vm_stats. Purpose of that patch was to allow other threads to run in non-preemptive case. This patch, makes sure that cond_resched() gets called when !CONFIG_PREEMPT is set. In a preemptiable kernel we don't need to call cond_resched().
> 
> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>

Let me ask questions.

1. What's bad if we call cond_resched on CONFIG_PREEMPT?
   Is refresh_cpu_vm_stats a hot path?
2. There is no help to call explicit scheduling point on CONFIG_PREEMPTION?
 
We used cond_resched without any ifdef/endif of CONFIG_PREEMPT.
In addtion, cond_resched includes __might_sleep which is debugging help for lock.
So I hope let it be if you have a big concern.

-- 
Kind regards
Meinchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
