Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C3E0B6B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 07:06:51 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning instead of failing
Date: Sun, 12 Jun 2011 13:07:20 +0200
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <20110602214655.GA2916@localhost.ucw.cz>
In-Reply-To: <20110602214655.GA2916@localhost.ucw.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106121307.20631.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, metan@ucw.cz, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Pavel,

On Thursday, June 02, 2011, Pavel Machek wrote:
> On Wed 2011-06-01 21:38:59, KOSAKI Motohiro wrote:
> > 2011/6/1 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>:
> > > Please be more polite to other people. After a197b59ae6 all allocations
> > > with GFP_DMA set on nodes without ZONE_DMA fail nearly silently (only
> > > one warning during bootup is emited, no matter how many things fail).
> > > This is a very crude change on behaviour. To be more civil, instead of
> > > failing emit noisy warnings each time smbd. tries to allocate a GFP_DMA
> > > memory on non-ZONE_DMA node.
> > >
> > > This change should be reverted after one or two major releases, but
> > > we should be more accurate rather than hoping for the best.
> > 
> > Instaed of, shouldn't we revert a197b59ae6? Some arch don't have
> > DMA_ZONE at all.
> > and a197b59ae6 only care x86 embedded case. If we accept your patch, I
> > can imagine
> > other people will claim warn foold is a bug. ;)
> 
> I believe we should revert. It broke zaurus boot for metan...

Is it still a problem, or has it been fixed in the meantime?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
