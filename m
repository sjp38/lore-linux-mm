Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 17985900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 03:55:39 -0400 (EDT)
Date: Thu, 14 Apr 2011 08:55:35 +0100
From: Matt Fleming <matt@console-pimps.org>
Subject: Re: [patch v2] oom: replace PF_OOM_ORIGIN with toggling
 oom_score_adj
Message-ID: <20110414085535.42559f6b@mfleming-mobl1.ger.corp.intel.com>
In-Reply-To: <BANLkTi=EVZJVdYSx7LitP__gPH4PBEJy6w@mail.gmail.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com>
	<20110414090310.07FF.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
	<BANLkTikx12d+vBpc6esRDYSaFr1dH+9HMA@mail.gmail.com>
	<alpine.DEB.2.00.1104131811470.19388@chino.kir.corp.google.com>
	<BANLkTi=EVZJVdYSx7LitP__gPH4PBEJy6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 10:21:56 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:
 
> Yes. We already have facilities for it(ex, task_lock, lock_task_sighand).
> And I think CAP_SYS_RESOURCE check in general function don't have a problem.
> 
> Of course, it adds unnecessary overhead slightly but it's not a hot
> path.  What's problem for you to go ahead?

Also, lock_task_sighand() would disable interrupts when acquiring
sighand->siglock, which this patch doesn't do, but should.

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
