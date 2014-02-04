Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 42A086B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:03:01 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so8325126pde.21
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:02:56 -0800 (PST)
Received: from blackbird.sr71.net ([198.145.64.142])
        by mx.google.com with ESMTP id qx4si25201193pbc.75.2014.02.04.08.02.26
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 08:02:27 -0800 (PST)
Message-ID: <52F10EFC.9090901@sr71.net>
Date: Tue, 04 Feb 2014 08:02:04 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] Kconfig: organize memory-related config options
References: <20140131172443.2EDC06E7@viggo.jf.intel.com> <20140131172448.3376826D@viggo.jf.intel.com>
In-Reply-To: <20140131172448.3376826D@viggo.jf.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

I'm sending this through the kbuild maintainer (Michal Marek), and he
asked that I collect a few acks from some mm folks.  I'm ccing the folks
who put some of these option in there, or touched them recently.  A
friendly ack or two would be appreciated.

On 01/31/2014 09:24 AM, Dave Hansen wrote:
> This continues in a series of patches to clean up the
> configuration menus.  I believe they've become really hard to
> navigate and there are some simple things we can do to make
> things easier to find.
> 
> This creates a "Memory Options" menu and moves some things like
> swap and slab configuration under them.  It also moves SLUB_DEBUG
> to the debugging menu.
> 
> After this patch, the menu has the following options:
> 
>   [ ] Memory placement aware NUMA scheduler
>   [*] Enable VM event counters for /proc/vmstat
>   [ ] Disable heap randomization
>   [*] Support for paging of anonymous memory (swap)
>       Choose SLAB allocator (SLUB (Unqueued Allocator))
>   [*] SLUB per cpu partial cache
>   [*] SLUB: attempt to use double-cmpxchg operations



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
