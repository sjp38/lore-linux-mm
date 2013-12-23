Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 68E956B0036
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 05:26:41 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so2254207eek.30
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 02:26:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si19342651eeo.116.2013.12.23.02.26.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Dec 2013 02:26:40 -0800 (PST)
Date: Mon, 23 Dec 2013 10:26:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/7] Configurable fair allocation zone policy v2r6
Message-ID: <20131223102637.GF11295@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <52B068B7.4070304@bitsync.net>
 <20131217212327.GL11295@suse.de>
 <52B5BBDF.9010200@bitsync.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52B5BBDF.9010200@bitsync.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zcalusic@bitsync.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Dec 21, 2013 at 05:03:43PM +0100, Zlatko Calusic wrote:
> On 17.12.2013 22:23, Mel Gorman wrote:
> >On Tue, Dec 17, 2013 at 04:07:35PM +0100, Zlatko Calusic wrote:
> >>On 13.12.2013 15:10, Mel Gorman wrote:
> >>>Kicked this another bit today. It's still a bit half-baked but it restores
> >>>the historical performance and leaves the door open at the end for playing
> >>>nice with distributing file pages between nodes. Finishing this series
> >>>depends on whether we are going to make the remote node behaviour of the
> >>>fair zone allocation policy configurable or redefine MPOL_LOCAL. I'm in
> >>>favour of the configurable option because the default can be redefined and
> >>>tested while giving users a "compat" mode if we discover the new default
> >>>behaviour sucks for some workload.
> >>>
> >>
> >>I'll start a 5-day test of this patchset in a few hours, unless you
> >>can send an updated one in the meantime. I intend to test it on a
> >>rather boring 4GB x86_64 machine that before Johannes' work had lots
> >>of trouble balancing zones. Would you recommend to use the default
> >>settings, i.e. don't mess with tunables at this point?
> >>
> >
> >For me at least I would prefer you tested v3 of the series with the
> >default settings of not interleaving file-backed pages on remote nodes
> >by default. Johannes might request testing with that knob enabled if the
> >machine is NUMA although I doubt it is with 4G of RAM.
> >
> 
> Tested v3 on UMA machine, with default setting. I see no regression,
> no issues whatsoever. From what I understand, this whole series is
> about fixing issues noticed on NUMA, so I wish you good luck with
> that (no such hardware here). Just be extra careful not to disturb
> finally very well balanced MM on more common machines (and
> especially those equipped with 4GB RAM). And once again thank you
> Johannes for your work, you did a great job.
> 
> Tested-by: Zlatko Calusic <zcalusic@bitsync.net>

Thanks for testing. Even though this patch is about NUMA, it preserves
the fair zone allocation policy on UMA that your workload depends upon.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
