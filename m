Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EF9A46008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 06:45:09 -0400 (EDT)
Received: by fxm11 with SMTP id 11so2646333fxm.14
        for <linux-mm@kvack.org>; Tue, 25 May 2010 03:45:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100525101924.GJ5087@laptop>
References: <20100524070309.GU2516@laptop>
	<alpine.DEB.2.00.1005240852580.5045@router.home>
	<20100525020629.GA5087@laptop>
	<AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
	<20100525070734.GC5087@laptop>
	<AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
	<20100525081634.GE5087@laptop>
	<AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
	<20100525093410.GH5087@laptop>
	<AANLkTikXp5LlKLK1deKOQpciUFNugjlQah5QpNcImf39@mail.gmail.com>
	<20100525101924.GJ5087@laptop>
Date: Tue, 25 May 2010 13:45:07 +0300
Message-ID: <AANLkTimazVL8G-XQURiQ1s0M3NKa2ndXNceSaw9sADRQ@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, May 25, 2010 at 1:19 PM, Nick Piggin <npiggin@suse.de> wrote:
>> Like I said, as a maintainer I'm happy to merge patches to modernize
>> SLAB
>
> I think that would be most productive at this point. I will volunteer
> to do it.

OK, great!

> As much as I would like to see SLQB be merged :) I think the best
> option is to go with SLAB because it is very well tested and very
> very well performing.

I would have liked to see SLQB merged as well but it just didn't happen.

> If Christoph or you or I or anyone have genuine improvements to make
> to the core algorithms, then the best thing to do will just be do
> make incremental changes to SLAB.

I don't see the problem in improving SLUB even if we start modernizing
SLAB. Do you? I'm obviously biased towards SLUB still for the reasons
I already mentioned. I don't want to be a blocker for progress so if I
turn out to be a problem, we should consider changing the
maintainer(s). ;-)

> There are several aspects to this. I think the first one will be to
> actually modernize the code style, simplify the bootstrap process and
> static memory allocations (SLQB goes even further than SLUB in this
> regard), and to pull in debug features from SLUB.
>
> These steps should be made without any changes to core algorithms.
> Alien caches can easily be disabled and at present they are really
> only a problem for big Altixes where it is a known parameter to tune.
>
> From that point, I think we should concede that SLUB has not fulfilled
> performance promises, and make SLAB the default.

Sure. I don't care which allocator "wins" if we actually are able to get there.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
