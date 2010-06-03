Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED896B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:32:13 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o53KW9rj023265
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:32:09 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz21.hot.corp.google.com with ESMTP id o53KVpHY003702
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:32:07 -0700
Received: by pzk2 with SMTP id 2so394453pzk.25
        for <linux-mm@kvack.org>; Thu, 03 Jun 2010 13:32:07 -0700 (PDT)
Date: Thu, 3 Jun 2010 13:32:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <1275551449.27810.34905.camel@twins>
Message-ID: <alpine.DEB.2.00.1006031327480.10856@chino.kir.corp.google.com>
References: <20100601173535.GD23428@uudg.org> <alpine.DEB.2.00.1006011347060.13136@chino.kir.corp.google.com> <20100602220429.F51E.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021410300.32666@chino.kir.corp.google.com> <1275551449.27810.34905.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, Peter Zijlstra wrote:

> > And that can reduce the runtime of the thread holding a writelock on 
> > mm->mmap_sem, making the exit actually take longer than without the patch 
> > if its priority is significantly higher, especially on smaller machines. 
> 
> /me smells an inversion... on -rt we solved those ;-)
> 

Right, but I don't see how increasing an oom killed tasks priority to a 
divine priority doesn't impact the priorities of other tasks which may be 
blocking the exit of that task, namely a coredumper or holder of 
mm->mmap_sem.  This patch also doesn't address how it negatively impacts 
the priorities of jobs running in different cpusets (although sharing the 
same cpus) because one cpuset is oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
