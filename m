Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2E07C6B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 10:09:34 -0400 (EDT)
Date: Thu, 25 Oct 2012 16:09:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121025140930.GF11105@dhcp22.suse.cz>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121023164546.747e90f6.akpm@linux-foundation.org>
 <20121024062938.GA6119@dhcp22.suse.cz>
 <20121024125439.c17a510e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121024125439.c17a510e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-10-12 12:54:39, Andrew Morton wrote:
> On Wed, 24 Oct 2012 08:29:45 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
[...]
> hmpf.  This patch worries me.  If there are people out there who are
> regularly using drop_caches because the VM sucks, it seems pretty
> obnoxious of us to go dumping stuff into their syslog.  What are they
> supposed to do?  Stop using drop_caches?  But that would unfix the
> problem which they fixed with drop_caches in the first case.
> 
> And they might not even have control over the code - they need to go
> back to their supplier and say "please send me a new version", along
> with all the additional costs and risks involed in an update.

I understand your worries and that's why I suggested a higher log level
which is under admin's control. Does even that sound too excessive?

> > > More friendly alternatives might be:
> > > 
> > > - Taint the kernel.  But that will only become apparent with an oops
> > >   trace or similar.
> > > 
> > > - Add a drop_caches counter and make that available in /proc/vmstat,
> > >   show_mem() output and perhaps other places.
> > 
> > We would loose timing and originating process name in both cases which
> > can be really helpful while debugging. It is fair to say that we could
> > deduce the timing if we are collecting /proc/meminfo or /proc/vmstat
> > already and we do collect them often but this is not the case all of the
> > time and sometimes it is important to know _who_ is doing all this.
> 
> But how important is all that?  The main piece of information the
> kernel developer wants is "this guy is using drop_caches a lot".  All
> the other info is peripheral and can be gathered by other means if so
> desired.

Well, I have experienced a debugging session where I suspected that an
excessive drop_caches is going on but I had hard time to prove who is
doing that (customer, of course, claimed they are not doing anything
like that) so we went through many loops until we could point the
finger.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
