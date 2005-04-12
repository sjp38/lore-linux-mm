Date: Tue, 12 Apr 2005 12:02:52 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [patch 1/4] pcp: zonequeues
In-Reply-To: <4257D74C.3010703@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0504121202060.7576@graphe.net>
References: <4257D74C.3010703@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jack Steiner <steiner@sgi.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Seems that this also effectively addresses the issues raised with the
pageset localization patches. Great work Nick!

On Sat, 9 Apr 2005, Nick Piggin wrote:

> Hi Jack,
> Was thinking about some problems in this area, and I hacked up
> a possible implementation to improve things.
>
> 1/4 switches the per cpu pagesets in struct zone to a single list
> of zone pagesets for each CPU.
>
> 2/4 changes the per cpu list of pagesets to a list of pointers to
> pagesets, and allocates them dynamically.
>
> 3/4 changes the code to allow NULL pagesets. In that case, a single
> per-zone pageset is used, which is protected by the zone's spinlock.
>
> 4/4 changes setup so non local zones don't have associated pagesets.
>
> It still needs some work - in particular, many NUMA systems probably
> don't want this. I guess benchmarks should be done, and maybe we
> could look at disabling the overhead of 3/4 and functional change of
> 4/4 depending on a CONFIG_ option.
>
> Also, you say you might want "close" remote nodes to have pagesets,
> but 4/4 only does local nodes. I added a comment with patch 4/4
> marked with XXX which should allow you to do this quite easily.
>
> Not tested (only compiled) on a NUMA system, but the NULL pagesets
> logic appears to work OK. Boots on a small UMA SMP system. So just
> be careful with it.
>
> Comments?
>
> --
> SUSE Labs, Novell Inc.
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
