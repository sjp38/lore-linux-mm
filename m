Date: Sun, 21 Dec 2003 20:34:30 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: load control demotion/promotion policy
In-Reply-To: <20031221235541.GA22896@k3.hellgate.ch>
Message-ID: <Pine.LNX.4.44.0312211913420.26393-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Dec 2003, Roger Luethi wrote:

> that working on load control is a lot more fun, it is _pageout_ that has
> been completely borked in 2.6 and there is no way in hell load control
> can fix that. Load control trades latency for throughput and makes sense
> for some situations after pageout tuning has been exhausted, which is
> not true at all for Linux 2.6.

I agree, pageout in 2.6 needs to be finetuned a bit more
to get that extra factor of 2 performance that's hiding
in a dark corner.

However, I don't think that obviates the need for load
control.  You have convinced me, though, that load
control is an emergency thing and shouldn't be meant
for regular use. 

Then again, I've wanted to work on load control for
years and would like to use this opportunity to have
some fun.

If you'd rather work on tuning the pageout code to make
that faster, I'd be happy to play around a bit with the
load control code ;))

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
