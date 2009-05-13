Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 77F9E6B00F7
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:43:08 -0400 (EDT)
Date: Wed, 13 May 2009 13:49:07 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
Message-ID: <20090513114907.GR19296@one.firstfloor.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com> <87r5ytl0nn.fsf@basil.nowhere.org> <2f11576a0905130418w1782f85j12cb938e92d256ff@mail.gmail.com> <20090513113817.GO19296@one.firstfloor.org> <28c262360905130441q8c904faq1d3e5152fada7a85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360905130441q8c904faq1d3e5152fada7a85@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 08:41:21PM +0900, Minchan Kim wrote:
> Hi, Andi.
> 
> On Wed, May 13, 2009 at 8:38 PM, Andi Kleen <andi@firstfloor.org> wrote:
> >> In past days, I proposed this. but Minchan found this config bloat kernel 7kb
> >> and he claim embedded guys should have selectable chance. I agreed it.
> >
> > Well there's lots of code in the kernel and 7k doesn't seem worth bothering.
> > If you just save two pages of memory somewhere you can save more.
> >
> >> Is this enough explanation?
> >
> > It's not a very good one.
> >
> > I would propose to just remove it or at least hide it completely
> > and only make it dependent on CONFIG_MMU inside Kconfig.
> 
> I thought this feature don't have a big impact on embedded.
> At First, 7K is not important but as time goes by, it could be huge

I don't follow. 7k is never huge, also not when time goes by.

In general saving text size is not very fruitful compared to the
savings you can get from optimizing dynamic memory allocation.
Most of the memory waste is in dynamic allocation. That's easy
to see because even on small systems there's much more (several
magnitudes) dynamic memory than kernel text.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
