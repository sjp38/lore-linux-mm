Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1D86B01F0
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 08:14:31 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o7PARovo031678
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 03:27:51 -0700
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz13.hot.corp.google.com with ESMTP id o7PARnuM016104
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 03:27:49 -0700
Received: by pwj4 with SMTP id 4so276664pwj.7
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 03:27:49 -0700 (PDT)
Date: Wed, 25 Aug 2010 03:27:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2][BUGFIX] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20100825184219.F3F2.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008250326150.16411@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com> <20100825184219.F3F2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010, KOSAKI Motohiro wrote:

> oom_adj is not only used for kernel knob, but also used for
> application interface.
> Then, adding new knob is no good reason to deprecate it.
> 
> Also, after former patch, oom_score_adj can't be used for setting
> OOM_DISABLE. We need "echo -17 > /proc/<pid>/oom_adj" thing.
> 
> This reverts commit 51b1bd2ace1595b72956224deda349efa880b693.

Since I nacked the parent patch of this, I implicitly nack this one as 
well since oom_score_adj shouldn't be going anywhere.  The way to disable 
oom killing for a task via the new interface, /proc/pid/oom_score_adj, is 
by OOM_SCORE_ADJ_MIN as specified in the documentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
