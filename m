Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C8776B015B
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 09:12:05 -0400 (EDT)
Received: by fxm2 with SMTP id 2so2127575fxm.4
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 06:12:04 -0700 (PDT)
From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: ipw2200: firmware DMA loading rework
Date: Mon, 21 Sep 2009 15:12:14 +0200
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <200909211246.34774.bzolnier@gmail.com> <1253530608.5216.17.camel@penberg-laptop>
In-Reply-To: <1253530608.5216.17.camel@penberg-laptop>
MIME-Version: 1.0
Message-Id: <200909211512.14785.bzolnier@gmail.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, "Luis R. Rodriguez" <mcgrof@gmail.com>, Tso Ted <tytso@mit.edu>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Zhu Yi <yi.zhu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@skynet.ie>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Ketrenos <jketreno@linux.intel.com>, "Chatre, Reinette" <reinette.chatre@intel.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "ipw2100-devel@lists.sourceforge.net" <ipw2100-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Monday 21 September 2009 12:56:48 Pekka Enberg wrote:
> On Mon, 2009-09-21 at 12:46 +0200, Bartlomiej Zolnierkiewicz wrote:
> > > > I don't know why people don't see it but for me it has a memory management
> > > > regression and reliability issue written all over it.
> > > 
> > > Possibly but drivers that reload their firmware as a response to an
> > > error condition is relatively new and loading network drivers while the
> > > system is already up and running a long time does not strike me as
> > > typical system behaviour.
> > 
> > Loading drivers after boot is a typical desktop/laptop behavior, please
> > think about hotplug (the hardware in question is an USB dongle).
> 
> Yeah, I wonder what broke things. Did the wireless stack change in
> 2.6.31-rc1 too? IIRC Mel ruled out page allocator changes as a suspect.

The thing is that the mm behavior change has been narrowed down already
over a month ago to -mm merge in 2.6.31-rc1 (as has been noted in my initial
reports), I first though that that it was -next breakage but it turned out
that it came the other way around (because -mm is not even pulled into -next
currently -- great way to set an example for other kernel maintainers BTW).

I understand that behavior change may be justified and technically correct
in itself.  I also completely agree that high order allocations in certain
drivers need fixing anyway.

However there is something wrong with the big picture and the way changes
are happening.  I'm not saying that I'm surprised though, especially given
the recent decline in the quality assurance and the paradigm shift that
I'm seeing (some influential top level people talking that -rc1 is fine for
testing new code now or the "new kernel new hardware" thing).

Sorry but I have no more time currently to narrow down the issue some more
(guess what, there are other kernel bugs standing in the way to bisect it
and I would have to provide some reliable way to reproduce it first) so I
see no more point in wasting people's time on this.  I can certainly get by
with allocation failure here and there.  Not a big deal for me personally..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
