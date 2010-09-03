Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EED596B00A2
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 07:01:22 -0400 (EDT)
Date: Fri, 3 Sep 2010 13:01:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Make is_mem_section_removable more conformable
 with offlining code
Message-ID: <20100903110114.GH10686@tiehlicka.suse.cz>
References: <20100902131855.GC10265@tiehlicka.suse.cz>
 <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
 <20100902143939.GD10265@tiehlicka.suse.cz>
 <20100902150554.GE10265@tiehlicka.suse.cz>
 <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903082558.GC10686@tiehlicka.suse.cz>
 <20100903181327.7dad3f84.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903095049.GG10686@tiehlicka.suse.cz>
 <20100903190520.8751aab6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903190520.8751aab6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri 03-09-10 19:05:20, KAMEZAWA Hiroyuki wrote:
> On Fri, 3 Sep 2010 11:50:49 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Fri 03-09-10 18:13:27, KAMEZAWA Hiroyuki wrote:
> > > On Fri, 3 Sep 2010 10:25:58 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > On Fri 03-09-10 12:14:52, KAMEZAWA Hiroyuki wrote:
> > > > [...]
> > [...]
> > > > Cannot ZONE_MOVABLE contain different MIGRATE_types?
> > > > 
> > > never.
> > 
> > Then I am terribly missing something. Zone contains free lists for
> > different MIGRATE_TYPES, doesn't it? Pages allocated from those free
> > lists keep the migration type of the list, right?
> > 
> > ZONE_MOVABLE just says whether it makes sense to move pages in that zone
> > at all, right?
> > 
> 
>  ZONE_MOVABLE means "it only contains MOVABLE pages."
>  So, we can ignore migrate-type.

Ahh. OK, it seems that I have to look over movable related code once
again. Maybe I just got confused from my experience when ZONE_MOVABLE
zone contained MIGRATE_RESERVE pages but now I can see that this is OK
and doesn't have anything to do with other migrate types.

Anyway, thank you for clarification.

[...]

> > > > Isn't this a problem? The function is triggered from userspace by sysfs
> > > > (0444 file) and holds the lock for pageblock_nr_pages. So someone can
> > > > simply read the file and block the zone->lock preventing/delaying
> > > > allocations for the rest of the system.
> > > > 
> > > But we need to take this. Maybe no panic you'll see even if no-lock.
> > 
> > Yes, I think that this can only lead to a false possitive in sysfs
> > interface. Isolating code holds the lock.
> > 
> 
> ok, let's go step by step.
> 
> I'm ok that your new patch to be merged. I'll post some clean up and small
> bugfix (not related to your patch), later.
> (I'll be very busy in this weekend, sorry.)

OK, no problem, we are not in hurry ;)

> 
> 
> Thanks,
> -Kame
> 

Thanks!

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
