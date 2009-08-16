Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 61B2B6B005A
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 06:18:05 -0400 (EDT)
Received: by bwz8 with SMTP id 8so1803774bwz.4
        for <linux-mm@kvack.org>; Sun, 16 Aug 2009 03:18:09 -0700 (PDT)
From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: mm/ipw2200 regression (was: Re: linux-next: Tree for August 6)
Date: Sun, 16 Aug 2009 12:17:12 +0200
References: <20090806192209.513abec7.sfr@canb.auug.org.au> <200908151856.48596.bzolnier@gmail.com> <20090816173101.6e47b702.sfr@canb.auug.org.au>
In-Reply-To: <20090816173101.6e47b702.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200908161217.12963.bzolnier@gmail.com>
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Hi,

On Sunday 16 August 2009 09:31:01 Stephen Rothwell wrote:
> Hi Bart,
> 
> On Sat, 15 Aug 2009 18:56:48 +0200 Bartlomiej Zolnierkiewicz <bzolnier@gmail.com> wrote:
> >
> > The bug managed to slip into Linus' tree..
> > 
> > ipw2200: Firmware error detected.  Restarting.
> > ipw2200/0: page allocation failure. order:6, mode:0x8020
> > Pid: 945, comm: ipw2200/0 Not tainted 2.6.31-rc6-dirty #69
>                                                    ^^^^^
> So, this is rc6 plus what?  (just in case it is relevant).

In this case plus upcoming staging/rt{286,287,307}0 patches (irrelevant,
they are not used on this machine and the problem happened many times
with vanilla -next kernels in the past)..

After going through mm commits in Linus' tree I think that the bug came
the other way around, from akpm's tree to Linus' tree and then to -next
(page allocator changes seem to match "the suspect's profile")..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
