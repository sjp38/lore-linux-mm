Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6C37F6B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 13:09:56 -0400 (EDT)
Received: by fxm20 with SMTP id 20so5198256fxm.38
        for <linux-mm@kvack.org>; Mon, 19 Oct 2009 10:09:53 -0700 (PDT)
Date: Mon, 19 Oct 2009 19:09:47 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091019170947.GA3782@bizet.domek.prywatny>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910190133.33183.elendil@planet.nl> <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <1255946051.5941.2.camel@penberg-laptop> <20091019140145.GA4222@bizet.domek.prywatny> <20091019140619.GD9036@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091019140619.GD9036@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Tobi Oetiker <tobi@oetiker.ch>, Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 03:06:19PM +0100, Mel Gorman wrote:
> Can you test with my kswapd patch applied and commits 373c0a7e,8aa7e847
> reverted please?

It seems that your patch and Frans' reverts together *do* make
difference.

With these patches I haven't been able to trigger failures so far
(in about 6 attempts). I'll continue testing and let you know if
anything changes.

If nothing changes this looks like fix for my problem.

Thanks.  Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
