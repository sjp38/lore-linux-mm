Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 160196B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 17:47:15 -0400 (EDT)
Date: Thu, 2 Jun 2011 21:46:56 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
	instead of failing
Message-ID: <20110602214655.GA2916@localhost.ucw.cz>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, metan@ucw.cz
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed 2011-06-01 21:38:59, KOSAKI Motohiro wrote:
> 2011/6/1 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>:
> > Please be more polite to other people. After a197b59ae6 all allocations
> > with GFP_DMA set on nodes without ZONE_DMA fail nearly silently (only
> > one warning during bootup is emited, no matter how many things fail).
> > This is a very crude change on behaviour. To be more civil, instead of
> > failing emit noisy warnings each time smbd. tries to allocate a GFP_DMA
> > memory on non-ZONE_DMA node.
> >
> > This change should be reverted after one or two major releases, but
> > we should be more accurate rather than hoping for the best.
> 
> Instaed of, shouldn't we revert a197b59ae6? Some arch don't have
> DMA_ZONE at all.
> and a197b59ae6 only care x86 embedded case. If we accept your patch, I
> can imagine
> other people will claim warn foold is a bug. ;)

I believe we should revert. It broke zaurus boot for metan...
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
