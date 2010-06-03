Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAC16B01DD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:37:38 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o536baVX031508
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:37:36 -0700
Received: from pzk15 (pzk15.prod.google.com [10.243.19.143])
	by wpaz1.hot.corp.google.com with ESMTP id o536bZ6E015152
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:37:35 -0700
Received: by pzk15 with SMTP id 15so2870043pzk.15
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:37:35 -0700 (PDT)
Date: Wed, 2 Jun 2010 23:37:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/12] oom: remove warning for in mm-less task
 __oom_kill_process()
In-Reply-To: <20100603145330.7259.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006022336440.22441@chino.kir.corp.google.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603145330.7259.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, KOSAKI Motohiro wrote:

> If the race of mm detach in task exiting vs oom is happen,
> find_lock_task_mm() can be return NULL.
> 
> So, the warning is pointless.
> 

Oh, please.  This isn't rc material.

I already remove this entire function in my patchset, why are you even 
bothering?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
