Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B91B56B004F
	for <linux-mm@kvack.org>; Sun, 18 Oct 2009 18:31:25 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 0/2] Reduce number of GFP_ATOMIC allocation failures
Date: Mon, 19 Oct 2009 00:31:15 +0200
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie> <20091017183421.GA3370@bizet.domek.prywatny> <20091018221844.GA2061@bizet.domek.prywatny>
In-Reply-To: <20091018221844.GA2061@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910190031.23237.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Karol,

On Monday 19 October 2009, Karol Lewandowski wrote:
> On Sat, Oct 17, 2009 at 08:34:21PM +0200, Karol Lewandowski wrote:
> > I'll go now for another round of bisecting... and hopefully this time
> > I'll be able to trigger this problem on different/faster computer with
> > e100-based card.
>
> No luck with that either.
>
> I've tried merging 'akpm' (517d08699b25) into clean 2.6.30 tree and
> got suspend-breakage which makes it untestable for me.  (I've tried
> reverting drm, suspend, and other commits... all that failed.)
>
> Is there mm-related git tree hidden somewhere?  ... or broken out
> mm-related patches that were sent to Andrew ... or maybe it's possible
> to get "git log -p" from Mel's private repo?  Anything?

Please try reverting 373c0a7e + 8aa7e847 [1] on top of 2.6.31. I've finally 
been able to solidly trace the main regression to that. I'm doing some 
final confirmation tests now and will mail detailed results afterwards.

It would be great if you could confirm if that fixes the issue for you too.

Cheers,
FJP

[1] The first commit is a build fix for the second.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
