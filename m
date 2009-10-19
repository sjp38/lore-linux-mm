Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 955A36B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 16:12:34 -0400 (EDT)
Date: Mon, 19 Oct 2009 22:12:31 +0200 (CEST)
From: Tobias Oetiker <tobi@oetiker.ch>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
In-Reply-To: <20091019145954.GH9036@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0910192211230.27123@sebohet.brgvxre.pu>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910190133.33183.elendil@planet.nl> <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <20091019133146.GB9036@csn.ul.ie>
 <alpine.DEB.2.00.0910191538450.8526@sebohet.brgvxre.pu> <20091019140957.GE9036@csn.ul.ie> <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu> <20091019145954.GH9036@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

Hi Mel,

Today Mel Gorman wrote:

> >
> > if you can send me a consolidated patch which does apply to
> > 2.6.31.4 I will be glad to try ...
> >
>
> Sure
>
> ==== CUT HERE ====
>
> From 6c0215af3b7c39ef7b8083ea38ca3ad93cd3f51f Mon Sep 17 00:00:00 2001
> From: Mel Gorman <mel@csn.ul.ie>
> Date: Mon, 19 Oct 2009 15:40:43 +0100
> Subject: [PATCH] Kick off kswapd after direct reclaim and revert congestion changes
>
> The following patch is http://lkml.org/lkml/2009/10/16/89 on top of
> 2.6.31.4 as well as patches 373c0a7e and 8aa7e847 reverted.

it seems to help ... the server has been running for 3 hours now
without incident, but then again it is not as active as during the
day, ... will report tomorrow.

cheers
tobi


-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
