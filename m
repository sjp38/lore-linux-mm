Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2B76B01EF
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 04:34:27 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o3M8YORX021807
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 01:34:24 -0700
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by wpaz17.hot.corp.google.com with ESMTP id o3M8YNTF014164
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 01:34:23 -0700
Received: by pwj2 with SMTP id 2so5480734pwj.3
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 01:34:23 -0700 (PDT)
Date: Thu, 22 Apr 2010 01:34:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100422092324.3900c5d4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004220132080.11176@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org> <alpine.DEB.2.00.1004211502430.25558@chino.kir.corp.google.com> <20100422092324.3900c5d4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010, KAMEZAWA Hiroyuki wrote:

> > I'm not going to allow a simple cleanup to jeopardize the entire patchset, 
> > so I can write a patch that readds /proc/sys/vm/oom_kill_allocating_task 
> > that simply mirrors the setting of /proc/sys/vm/oom_kill_quick and then 
> > warn about its deprecation. 
> 
> Yeah, I welcome it.
> 

Ok, good.

> > I don't believe we need to do the same thing 
> > for the removal of /proc/sys/vm/oom_dump_tasks since that functionality is 
> > now enabled by default.
> > 
> 
> But *warning* is always apprecieated and will not make the whole patches
> too dirty. So, please write one.
> 
> BTW, I don't think there is an admin who turns off oom_dump_task..
> So, just keeping interface and putting this one to feature-removal-list 
> is okay for me if you want to cleanup sysctl possibly.
> 

Do we really need to keep oom_dump_tasks around since the result of this 
patchset is that we've enabled it by default?  It seems to me like users 
who now want to disable it (something that nobody is currently doing, it's 
the default in Linus' tree) can simply do

	echo 1 > /proc/sys/vm/oom_kill_quick

instead to both suppress the tasklist scan for the dump and for the target 
selection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
