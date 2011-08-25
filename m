Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 354966B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 12:48:03 -0400 (EDT)
Date: Thu, 25 Aug 2011 18:47:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-ID: <20110825164758.GB22564@tiehlicka.suse.cz>
References: <20110823073101.6426.77745.stgit@zurg>
 <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com>
 <20110824101927.GB3505@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
 <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110825151818.GA4003@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu 25-08-11 17:18:18, Oleg Nesterov wrote:
> On 08/25, Michal Hocko wrote:
> >
> > On Wed 24-08-11 12:31:26, David Rientjes wrote:
> > >
> > > That's obviously false since we call oom_killer_disable() in 
> > > freeze_processes() to disable the oom killer from ever being called in the 
> > > first place, so this is something you need to resolve with Rafael before 
> > > you cause more machines to panic.
> >
> > I didn't mean suspend/resume path (that is protected by oom_killer_disabled)
> > so the patch doesn't make any change.
> 
> Confused... freeze_processes() does try_to_freeze_tasks() before
> oom_killer_disable() ?

Yes you are right, I must have been blind. 

Now I see the point. We do not want to panic while we are suspending and
the memory is really low just because all the userspace is already in
the the fridge.
Sorry for confusion.

I still do not follow the oom_killer_disable note from David, though.

> 
> Oleg.

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
