Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6866B01D9
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:35:00 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o536Yv5c023110
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:34:57 -0700
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by wpaz9.hot.corp.google.com with ESMTP id o536Yt1i007905
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:34:56 -0700
Received: by pzk38 with SMTP id 38so3780913pzk.31
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:34:55 -0700 (PDT)
Date: Wed, 2 Jun 2010 23:34:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 09/12] oom: remove PF_EXITING check completely
In-Reply-To: <20100603152436.7262.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152436.7262.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, KOSAKI Motohiro wrote:

> Currently, PF_EXITING check is completely broken. because 1) It only
> care main-thread and ignore sub-threads

Then check the subthreads.

> 2) If user enable core-dump
> feature, it can makes deadlock because the task during coredump ignore
> SIGKILL.
> 

It may ignore SIGKILL, but does not ignore fatal_signal_pending() being 
true which gives it access to memory reserves with my patchset so that it 
may quickly finish.

> The deadlock is certenaly worst result, then, minor PF_EXITING
> optimization worth is relatively ignorable.
> 
> This patch removes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Oleg Nesterov <oleg@redhat.com>

Nacked-by: David Rientjes <rientjes@google.com>

You have no real world experience in using the oom killer for memory 
containment and don't understand how critical it is to protect other 
vital system tasks that are needlessly killed as the result of this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
