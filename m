Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 889326B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 13:57:35 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id fe20so5019506lab.34
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 10:57:33 -0700 (PDT)
Date: Tue, 9 Jul 2013 21:57:29 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130709175632.GC9188@localhost.localdomain>
References: <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
 <20130708125352.GC20149@dhcp22.suse.cz>
 <20130709173242.GA9098@localhost.localdomain>
 <20130709105032.f9acb85a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130709105032.f9acb85a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 09, 2013 at 10:50:32AM -0700, Andrew Morton wrote:
> On Tue, 9 Jul 2013 21:32:51 +0400 Glauber Costa <glommer@gmail.com> wrote:
> 
> > > $ dmesg | grep "blocked for more than"
> > > [276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > > [276962.653097] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
> > > [276962.653940] INFO: task ld:14442 blocked for more than 480 seconds.
> > > [276962.654297] INFO: task ld:14962 blocked for more than 480 seconds.
> > > [277442.652123] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > > [277442.653153] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
> > > [277442.653997] INFO: task ld:14442 blocked for more than 480 seconds.
> > > [277442.654353] INFO: task ld:14962 blocked for more than 480 seconds.
> > > [277922.652069] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > > [277922.653089] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
> > > 
> > 
> > You seem to have switched to XFS. Dave posted a patch two days ago fixing some
> > missing conversions in the XFS side. AFAIK, Andrew hasn't yet picked the patch.
> 
> I can't find that patch.  Please resend?
> 
> There's also "list_lru: fix broken LRU_RETRY behaviour", which I
> assume we need?

Yes, we can either apply or stash that one - up to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
