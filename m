Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9E76B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 22:04:54 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o8G24p2d024476
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 19:04:52 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by kpbe12.cbf.corp.google.com with ESMTP id o8G24oXp013952
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 19:04:50 -0700
Received: by pzk32 with SMTP id 32so248971pzk.8
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 19:04:50 -0700 (PDT)
Date: Wed, 15 Sep 2010 19:04:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: filter unkillable tasks from tasklist dump
In-Reply-To: <alpine.DEB.2.00.1009011426260.28408@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1009151903560.6001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009011426260.28408@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Sep 2010, David Rientjes wrote:

> /proc/sys/vm/oom_dump_tasks is enabled by default, so it's necessary to
> limit as much information as possible that it should emit.
> 
> The tasklist dump should be filtered to only those tasks that are
> eligible for oom kill.  This is already done for memcg ooms, but this
> patch extends it to both cpuset and mempolicy ooms as well as init.
> 
> In addition to suppressing irrelevant information, this also reduces
> confusion since users currently don't know which tasks in the tasklist
> aren't eligible for kill (such as those attached to cpusets or bound to
> mempolicies with a disjoint set of mems or nodes, respectively) since
> that information is not shown.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Andrew, did you have a chance to look at this and consider it for -mm?

Please also add KOSAKI-san's Reviewed-by line from 
http://marc.info/?l=linux-mm&m=128338679018068.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
