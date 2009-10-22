Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B722C6B004D
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 10:47:12 -0400 (EDT)
Received: by qyk14 with SMTP id 14so5322240qyk.11
        for <linux-mm@kvack.org>; Thu, 22 Oct 2009 07:47:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Date: Thu, 22 Oct 2009 17:47:10 +0300
Message-ID: <84144f020910220747nba30d8bkc83c2569da79bd7c@mail.gmail.com>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 22, 2009 at 5:22 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> Test 1: Verify your problem occurs on 2.6.32-rc5 if you can
>
> Test 2: Apply the following two patches and test again
>
> =A01/5 page allocator: Always wake kswapd when restarting an allocation a=
ttempt after direct reclaim failed
> =A02/5 page allocator: Do not allow interrupts to use ALLOC_HARDER

These are pretty obvious bug fixes and should go to linux-next ASAP IMHO.

> Test 5: If things are still screwed, apply the following
> =A05/5 Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async vs rea=
d/write confusion
>
> =A0 =A0 =A0 =A0Frans Pop reports that the bulk of his problems go away wh=
en this
> =A0 =A0 =A0 =A0patch is reverted on 2.6.31. There has been some confusion=
 on why
> =A0 =A0 =A0 =A0exactly this patch was wrong but apparently the conversion=
 was not
> =A0 =A0 =A0 =A0complete and further work was required. It's unknown if al=
l the
> =A0 =A0 =A0 =A0necessary work exists in 2.6.31-rc5 or not. If there are s=
till
> =A0 =A0 =A0 =A0allocation failures and applying this patch fixes the prob=
lem,
> =A0 =A0 =A0 =A0there are still snags that need to be ironed out.

As explained by Jens Axboe, this changes timing but is not the source
of the OOMs so the revert is bogus even if it "helps" on some
workloads. IIRC the person who reported the revert to help things did
report that the OOMs did not go away, they were simply harder to
trigger with the revert.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
