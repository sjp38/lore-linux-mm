Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 132196B01D0
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 23:36:24 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o5H3aMGn006816
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:36:22 -0700
Received: from pxi18 (pxi18.prod.google.com [10.243.27.18])
	by hpaq3.eem.corp.google.com with ESMTP id o5H3aK9h023458
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:36:20 -0700
Received: by pxi18 with SMTP id 18so707378pxi.40
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:36:19 -0700 (PDT)
Date: Wed, 16 Jun 2010 20:36:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 18/18] oom: deprecate oom_adj tunable
In-Reply-To: <20100613201922.619C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006162034330.21446@chino.kir.corp.google.com>
References: <20100608194514.7654.A69D9226@jp.fujitsu.com> <20100608161844.04d2f2a1.akpm@linux-foundation.org> <20100613201922.619C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jun 2010, KOSAKI Motohiro wrote:

> But oom_score_adj have no benefit form end-uses view. That's problem.
> Please consider to make end-user friendly good patch at first.
> 

Of course it does, it actually has units whereas oom_adj only grows or 
shrinks the badness score exponentially.  oom_score_adj's units are well 
understood: on a machine with 4G of memory, 250 means we're trying to 
prejudice it by 1G of memory so that can be used by other tasks, -250 
means other tasks should be prejudiced by 1G in comparison to this task, 
etc.  It's actually quite powerful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
