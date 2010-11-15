Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ED1AA8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:04:27 -0500 (EST)
Date: Mon, 15 Nov 2010 08:04:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] set_pgdat_percpu_threshold() don't use
 for_each_online_cpu
In-Reply-To: <20101115102617.GK27362@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1011150802470.19175@router.home>
References: <1288169256-7174-2-git-send-email-mel@csn.ul.ie> <20101028100920.5d4ce413.kamezawa.hiroyu@jp.fujitsu.com> <20101114163727.BEE0.A69D9226@jp.fujitsu.com> <20101115102617.GK27362@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, Mel Gorman wrote:

> With recent per-cpu allocator changes, are we guaranteed that the per-cpu
> structures exist and are valid?

We always guarantee that all per cpu areas for all possible cpus exist.
That has always been the case. There was a discussion about changing
that though. Could be difficult given the need for additional locking.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
