Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 695F16B003D
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:14:52 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x13so12853884wgg.15
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:14:51 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw3si12473706wjb.23.2014.02.04.08.14.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:14:51 -0800 (PST)
Date: Tue, 4 Feb 2014 17:14:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] Kconfig: organize memory-related config options
Message-ID: <20140204161450.GP4890@dhcp22.suse.cz>
References: <20140131172443.2EDC06E7@viggo.jf.intel.com>
 <20140131172448.3376826D@viggo.jf.intel.com>
 <52F10EFC.9090901@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F10EFC.9090901@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Marek <mmarek@suse.cz>

On Tue 04-02-14 08:02:04, Dave Hansen wrote:
> I'm sending this through the kbuild maintainer (Michal Marek), and he

Wrong Michal ;) CCed now.

> asked that I collect a few acks from some mm folks.  I'm ccing the folks
> who put some of these option in there, or touched them recently.  A
> friendly ack or two would be appreciated.
> 
> On 01/31/2014 09:24 AM, Dave Hansen wrote:
> > This continues in a series of patches to clean up the
> > configuration menus.  I believe they've become really hard to
> > navigate and there are some simple things we can do to make
> > things easier to find.
> > 
> > This creates a "Memory Options" menu and moves some things like
> > swap and slab configuration under them.  It also moves SLUB_DEBUG
> > to the debugging menu.
> > 
> > After this patch, the menu has the following options:
> > 
> >   [ ] Memory placement aware NUMA scheduler
> >   [*] Enable VM event counters for /proc/vmstat
> >   [ ] Disable heap randomization
> >   [*] Support for paging of anonymous memory (swap)
> >       Choose SLAB allocator (SLUB (Unqueued Allocator))
> >   [*] SLUB per cpu partial cache
> >   [*] SLUB: attempt to use double-cmpxchg operations
> 
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
