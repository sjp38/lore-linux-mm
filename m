Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA789000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 04:04:49 -0400 (EDT)
Date: Fri, 30 Sep 2011 10:04:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] oom: thaw threads if oom killed thread is frozen before
 deferring
Message-ID: <20110930080445.GC32134@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1109271133590.17876@chino.kir.corp.google.com>
 <20110928104445.GB15062@tiehlicka.suse.cz>
 <20110929115105.GE21113@tiehlicka.suse.cz>
 <20110929120517.GA10587@redhat.com>
 <20110929130204.GG21113@tiehlicka.suse.cz>
 <20110929163724.GA23773@redhat.com>
 <20110929180021.GA27999@tiehlicka.suse.cz>
 <20110930015148.GD10425@mtj.dyndns.org>
 <20110930074125.GB32134@tiehlicka.suse.cz>
 <20110930074641.GK10425@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110930074641.GK10425@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 30-09-11 00:46:41, Tejun Heo wrote:
> Hello,
> 
> On Fri, Sep 30, 2011 at 09:41:25AM +0200, Michal Hocko wrote:
> > > With pending freezer changes, allowing TIF_MEMDIE tasks to exit
> > > freezer by modifying freezing() shouldn't be difficult, which should
> > > be race-free and much simpler than diddling with thaw_task().  
> > 
> > Will the rework help with the initial problem of unkillable OOM selected
> > frozen tasks or it will just help with other races that might be present
> > with the patch? In other words will this work deprecate the 2 patches
> > sent earlier in this thread?
> 
> I think it shouldn't be difficult to allow OOM-killing frozen tasks.
> That should be good enough, right?

Yes, if you could just force_sig(SIGKILL, p) frozen task then it would
be ideal because we wouldn't have to call thaw_process from OOM path.

> 
> > > How urgent is this?  Can we wait for the next merge window?
> > 
> > Yes, I think we can wait some more.
> 
> I'm still processing rather large backlog.  I'll ping you back once I
> sort out the pending freezer changes.

You were on the CC quite early but it was quite late when I noticed that
I have accidentally used your kernel.org address. Just for reference the
original discussion started here: https://lkml.org/lkml/2011/8/23/45 and
this thread started here:
http://www.spinics.net/lists/linux-mm/msg24693.html

> 
> Thanks.
> 
> -- 
> tejun
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
