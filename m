Date: Wed, 7 Mar 2001 08:25:19 +0100 (CET)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Linux 2.2 vs 2.4 for PostgreSQL
In-Reply-To: <Pine.LNX.4.10.10103061626070.20708-100000@sphinx.mythic-beasts.com>
Message-ID: <Pine.LNX.4.33.0103070722080.1086-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Kirkwood <matthew@hairy.beasts.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2001, Matthew Kirkwood wrote:

> Draw your own, but:
>  * 2.4's IO scheduling doesn't seem as good as 2.2's yet
>  * But it's getting better
>  * Mike's patch was about 3-5% worse on this workload
>    with fsync on and 3% better with it off (except on
>    one run, which I think may be an anomaly)

Just looking at the 2.4 numbers:  My adjustment is a rob Peter
to pay Paul tradeoff.  I'm glad Peter didn't get seriously injured
during the mugging ;-)  Looking at 2.4.2p2->2.4.2ac11+fix, there's
still a gain for this load.  I see more of a net gain with my load
though.  Flattening the ac11 peak for this load raised the valley
for another type load such that both gained some in the end.

I'd really like to hear from the folks who were griping about their
workstation performance though to see if the compromise was a good
one for them.. or not.  So far, I've heard nothing either positive
or negative.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
