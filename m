Date: Mon, 3 Mar 2008 20:55:34 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 12/21] No Reclaim LRU Infrastructure
Message-ID: <20080303205534.2939d584@bree.surriel.com>
In-Reply-To: <47CC8C0C.9080502@gmail.com>
References: <20080228192908.126720629@redhat.com>
	<20080228192929.031646681@redhat.com>
	<44c63dc40802282058h67f7597bvb614575f06c62e2c@mail.gmail.com>
	<1204296534.5311.8.camel@localhost>
	<44c63dc40803021904n5de681datba400e08079c152d@mail.gmail.com>
	<20080303134634.5893b5e0@cuia.boston.redhat.com>
	<47CC8C0C.9080502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "barrioskmc@gmail" <minchan.kim@gmail.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 04 Mar 2008 08:38:52 +0900
"barrioskmc@gmail" <minchan.kim@gmail.com> wrote:
> Rik van Riel wrote:
> > On Mon, 3 Mar 2008 12:04:14 +0900
> > "minchan Kim" <barrioskmc@gmail.com> wrote:
> > 
> >> One more thing.
> >>
> >> zoneinfo_show_print fail to show right information.
> >> That's why 'enum zone_stat_item' and 'vmstat_text' index didn't matched.
> >> This is a problem about CONFIG_NORECLAIM, too.
> > 
> > In what configuration do they not line up, and why?
> > 
> > AFAICS the #ifdefs in zone_stat_item and vmstat_text match up...
> > 
> 
> So sorry, It was my mistake.
> I seem to have a bad eye :(

Not at all.  You found a number of real issues with my patch series,
which I have fixed today.  I am happy that people like you take a
good look at my patches, so I get a chance to improve them.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
