Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C9EC96B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 12:40:03 -0400 (EDT)
Date: Fri, 28 Sep 2012 16:40:02 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] make GFP_NOTRACK flag unconditional
In-Reply-To: <5065B42F.5010007@parallels.com>
Message-ID: <0000013a0dbfc498-6debffd5-cd68-404c-92a4-4f88d40cf41b-000000@email.amazonses.com>
References: <1348826194-21781-1-git-send-email-glommer@parallels.com> <0000013a0d475174-343e3b17-6755-42c1-9dae-a9287ad7d403-000000@email.amazonses.com> <5065B42F.5010007@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> On 09/28/2012 06:28 PM, Christoph Lameter wrote:
> > On Fri, 28 Sep 2012, Glauber Costa wrote:
> >
> >> There was a general sentiment in a recent discussion (See
> >> https://lkml.org/lkml/2012/9/18/258) that the __GFP flags should be
> >> defined unconditionally. Currently, the only offender is GFP_NOTRACK,
> >> which is conditional to KMEMCHECK.
> >>
> >> This simple patch makes it unconditional.
> >
> > __GFP_NOTRACK is only used in context where CONFIG_KMEMCHECK is defined?
> >
> > If that is not the case then you need to define GFP_NOTRACK and substitute
> > it where necessary.
> >
>
> The flag is passed around extensively, but I was imagining the whole
> point of that is that having the flag itself is harmless, and will be
> ignored by the page allocator ?

Looking through it shows almost nothing that is affected.

One thing though is that defining __GFP_NOTRACK to 0 eliminates an "or"
operation in alloc_slab_page().

That is already on the slob path so I guess that is minimal

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
