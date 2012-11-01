Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id A27CC6B0078
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 16:26:56 -0400 (EDT)
Date: Thu, 1 Nov 2012 21:26:54 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121101202503.GA20817@xo-6d-61-c0.localdomain>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121023164546.747e90f6.akpm@linux-foundation.org>
 <20121024062938.GA6119@dhcp22.suse.cz>
 <20121024125439.c17a510e.akpm@linux-foundation.org>
 <50884F63.8030606@linux.vnet.ibm.com>
 <20121024134836.a28d223a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121024134836.a28d223a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

Hi!

> > > hmpf.  This patch worries me.  If there are people out there who are
> > > regularly using drop_caches because the VM sucks, it seems pretty
> > > obnoxious of us to go dumping stuff into their syslog.  What are they
> > > supposed to do?  Stop using drop_caches?
> > 
> > People use drop_caches because they _think_ the VM sucks, or they
> > _think_ they're "tuning" their system.  _They_ are supposed to stop
> > using drop_caches. :)
> 
> Well who knows.  Could be that people's vm *does* suck.  Or they have
> some particularly peculiar worklosd or requirement[*].  Or their VM
> *used* to suck, and the drop_caches is not really needed any more but
> it's there in vendor-provided code and they can't practically prevent
> it.

Or they have ipw wifi that does order 5 allocation :-).

I seen drop_caches used in some android code, as part of SD card handling IIRC.

> > What kind of interface _is_ it in the first place?  Is it really a
> > production-level thing that we expect users to be poking at?  Or, is it
> > a rarely-used debugging and benchmarking knob which is fair game for us
> > to tweak like this?
> 
> It was a rarely-used mainly-developer-only thing which, apparently, real
> people found useful at some point in the past.  Perhaps we should never
> have offered it.

And yes, documentation would be good. IIRC you claimed that
drop_caches is not safe to use year-or-so-ago, is that still true?

										Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
