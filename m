Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C6D036B016A
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 03:59:23 -0400 (EDT)
Date: Wed, 27 Jul 2011 09:59:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] oom: avoid killing kthreads if they assume the oom
 killed thread's mm
Message-ID: <20110727075921.GB4024@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1107251711460.26480@chino.kir.corp.google.com>
 <20110726152724.GE17958@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1107261502410.19338@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107261502410.19338@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue 26-07-11 15:05:23, David Rientjes wrote:
> On Tue, 26 Jul 2011, Michal Hocko wrote:
> 
> > > After selecting a task to kill, the oom killer iterates all processes and
> > > kills all other threads that share the same mm_struct in different thread
> > > groups.  It would not otherwise be helpful to kill a thread if its memory
> > > would not be subsequently freed.
> > > 
> > > A kernel thread, however, may assume a user thread's mm by using
> > > use_mm().  This is only temporary and should not result in sending a
> > > SIGKILL to that kthread.
> > 
> > Good catch. Have you ever seen this happening?
> > 
> 
> No, this is just another patch to make the kernel more use_mm()-friendly.  
> Before that capability was introduced, it was possible to assume that a 
> kthread would always have a NULL mm pointer, so it wasn't previously 
> required for this code.

OK

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
