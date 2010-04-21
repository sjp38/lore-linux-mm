Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBB26B0200
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 18:04:39 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o3LM4YtP016625
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 15:04:35 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by kpbe17.cbf.corp.google.com with ESMTP id o3LM3iUX032214
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 15:04:33 -0700
Received: by pwi1 with SMTP id 1so5594479pwi.25
        for <linux-mm@kvack.org>; Wed, 21 Apr 2010 15:04:32 -0700 (PDT)
Date: Wed, 21 Apr 2010 15:04:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100421121758.af52f6e0.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1004211502430.25558@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Apr 2010, Andrew Morton wrote:

> fyi, I still consider these patches to be in the "stuck" state.  So we
> need to get them unstuck.
> 
> 
> Hiroyuki (and anyone else): could you please summarise in the briefest
> way possible what your objections are to Daivd's oom-killer changes?
> 
> I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
> change it we don't change it without warning.
> 

I'm not going to allow a simple cleanup to jeopardize the entire patchset, 
so I can write a patch that readds /proc/sys/vm/oom_kill_allocating_task 
that simply mirrors the setting of /proc/sys/vm/oom_kill_quick and then 
warn about its deprecation.  I don't believe we need to do the same thing 
for the removal of /proc/sys/vm/oom_dump_tasks since that functionality is 
now enabled by default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
