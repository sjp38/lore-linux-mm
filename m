Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 160446B004F
	for <linux-mm@kvack.org>; Sun, 18 Oct 2009 18:18:50 -0400 (EDT)
Received: by fxm20 with SMTP id 20so4257521fxm.38
        for <linux-mm@kvack.org>; Sun, 18 Oct 2009 15:18:49 -0700 (PDT)
Date: Mon, 19 Oct 2009 00:18:44 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/2] Reduce number of GFP_ATOMIC allocation failures
Message-ID: <20091018221844.GA2061@bizet.domek.prywatny>
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie> <20091017183421.GA3370@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091017183421.GA3370@bizet.domek.prywatny>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Frans Pop <elendil@planet.nl>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 17, 2009 at 08:34:21PM +0200, Karol Lewandowski wrote:

> I'll go now for another round of bisecting... and hopefully this time
> I'll be able to trigger this problem on different/faster computer with
> e100-based card.

No luck with that either.

I've tried merging 'akpm' (517d08699b25) into clean 2.6.30 tree and
got suspend-breakage which makes it untestable for me.  (I've tried
reverting drm, suspend, and other commits... all that failed.)

Is there mm-related git tree hidden somewhere?  ... or broken out
mm-related patches that were sent to Andrew ... or maybe it's possible
to get "git log -p" from Mel's private repo?  Anything?

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
