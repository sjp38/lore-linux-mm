Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B360D6B009E
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 06:56:43 -0400 (EDT)
Subject: Re: ipw2200: firmware DMA loading rework
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <200909211246.34774.bzolnier@gmail.com>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera>
	 <200909211159.27344.bzolnier@gmail.com> <20090921100813.GL12726@csn.ul.ie>
	 <200909211246.34774.bzolnier@gmail.com>
Date: Mon, 21 Sep 2009 13:56:48 +0300
Message-Id: <1253530608.5216.17.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "Luis R. Rodriguez" <mcgrof@gmail.com>, Tso Ted <tytso@mit.edu>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Zhu Yi <yi.zhu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@skynet.ie>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Ketrenos <jketreno@linux.intel.com>, "Chatre, Reinette" <reinette.chatre@intel.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "ipw2100-devel@lists.sourceforge.net" <ipw2100-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-09-21 at 12:46 +0200, Bartlomiej Zolnierkiewicz wrote:
> > > I don't know why people don't see it but for me it has a memory management
> > > regression and reliability issue written all over it.
> > 
> > Possibly but drivers that reload their firmware as a response to an
> > error condition is relatively new and loading network drivers while the
> > system is already up and running a long time does not strike me as
> > typical system behaviour.
> 
> Loading drivers after boot is a typical desktop/laptop behavior, please
> think about hotplug (the hardware in question is an USB dongle).

Yeah, I wonder what broke things. Did the wireless stack change in
2.6.31-rc1 too? IIRC Mel ruled out page allocator changes as a suspect.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
