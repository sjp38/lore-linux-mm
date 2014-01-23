Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 50D3A6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 19:16:54 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so1103196pab.16
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 16:16:53 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id p3si11730579pbj.68.2014.01.22.16.16.51
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 16:16:52 -0800 (PST)
Date: Thu, 23 Jan 2014 09:18:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zswap: add writethrough option
Message-ID: <20140123001806.GF31230@bbox>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
 <20140114001115.GU1992@bbox>
 <CALZtONCCrckuHxgHB=GQj0tHszLAYTZZLGzFTnRkj9pvxx0dyg@mail.gmail.com>
 <20140115054208.GL1992@bbox>
 <CALZtONCehE8Td2C2w-fOC596uD54y1-kyc3SiKABBEODMb+a7Q@mail.gmail.com>
 <CALZtONAaPCi8eUhSmdXSxWbeFFN=ChsfL9OurSZUsSPo-_gnfg@mail.gmail.com>
 <20140122123358.a65c42605513fc8466152801@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122123358.a65c42605513fc8466152801@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

Hello all,

On Wed, Jan 22, 2014 at 12:33:58PM -0800, Andrew Morton wrote:
> On Wed, 22 Jan 2014 09:19:58 -0500 Dan Streetman <ddstreet@ieee.org> wrote:
> 
> > >>> > Acutally, I really don't know how much benefit we have that in-memory
> > >>> > swap overcomming to the real storage but if you want, zRAM with dm-cache
> > >>> > is another option rather than invent new wheel by "just having is better".
> > >>>
> > >>> I'm not sure if this patch is related to the zswap vs. zram discussions.  This
> > >>> only adds the option of using writethrough to zswap.  It's a first
> > >>> step to possibly
> > >>> making zswap work more efficiently using writeback and/or writethrough
> > >>> depending on
> > >>> the system and conditions.
> > >>
> > >> The patch size is small. Okay I don't want to be a party-pooper
> > >> but at least, I should say my thought for Andrew to help judging.
> > >
> > > Sure, I'm glad to have your suggestions.
> > 
> > To give this a bump - Andrew do you have any concerns about this
> > patch?  Or can you pick this up?
> 
> I don't pay much attention to new features during the merge window,
> preferring to shove them into a folder to look at later.  Often they
> have bitrotted by the time -rc1 comes around.
> 
> I'm not sure that this review discussion has played out yet - is
> Minchan happy?

>From the beginning, zswap is for reducing swap I/O but if workingset
overflows, it should write back rather than OOM with expecting a small
number of writeback would make the system happy because the high memory
pressure is temporal so soon most of workload would be hit in zswap
without further writeback.

If memory pressure continues and writeback steadily, it means zswap's
benefit would be mitigated, even worse by addding comp/decomp overhead.
In that case, it would be better to disable zswap, even.

Dan said writethrough supporting is first step to make zswap smart
but anybody didn't say further words to step into the smart and
what's the *real* workload want it and what's the *real* number from
that because dm-cache/zram might be a good fit.
(I don't intend to argue zram VS zswap. If the concern is solved by
existing solution, why should we invent new function and
have maintenace cost?) so it's very hard for me to judge that we should
accept and maintain it.

We need blueprint for the future and make an agreement on the
direction before merging this patch.

But code size is not much and Seth already gave an his Ack so I don't
want to hurt Dan any more(Sorry for Dan) and wasting my time so pass
the decision to others(ex, Seth and Bob).
If they insist on, I don't object any more.

Sorry for bothering Dan.

Thanks.

> 
> Please update the changelog so that it reflects the questions Minchan
> asked (any reviewer question should be regarded as an inadequacy in
> either the code commenting or the changelog - people shouldn't need to
> ask the programmer why he did something!) and resend for -rc1?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
