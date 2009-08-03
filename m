Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D4DDF6B0088
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 03:50:47 -0400 (EDT)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n7388lqM005034
	for <linux-mm@kvack.org>; Mon, 3 Aug 2009 09:08:48 +0100
Received: from pxi41 (pxi41.prod.google.com [10.243.27.41])
	by spaceape10.eur.corp.google.com with ESMTP id n7388iWB010802
	for <linux-mm@kvack.org>; Mon, 3 Aug 2009 01:08:45 -0700
Received: by pxi41 with SMTP id 41so51590pxi.23
        for <linux-mm@kvack.org>; Mon, 03 Aug 2009 01:08:44 -0700 (PDT)
Date: Mon, 3 Aug 2009 01:08:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090803170217.e98b2e46.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0908030107110.30778@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com> <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com> <20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com> <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com> <7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
 <alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com> <77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com> <alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com> <20090803104244.b58220ba.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0908030050160.30778@chino.kir.corp.google.com> <20090803170217.e98b2e46.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009, KAMEZAWA Hiroyuki wrote:

> > You can't recalculate it if all the remaining threads have a different 
> > oom_adj value than the effective oom_adj value from the thread that is now 
> > exited.  
> 
> Then, crazy google apps pass different oom_adjs to each thread ?
> And, threads other than thread-group-leader modifies its oom_adj.
> 

Nope, but I'm afraid you've just made my point for me: it shows that 
oom_adj really isn't sanely used as a per-thread attribute and actually 
only represents a preference on oom killing a quantity of memory in all 
other cases other than vfork() -> change /proc/pid-of-child/oom_adj -> 
exec() for which we now appropriately have /proc/pid/oom_adj_child for.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
