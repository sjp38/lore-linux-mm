Date: Tue, 30 May 2006 17:13:22 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [stable] [PATCH 0/2] Zone boundary alignment fixes, default configuration
Message-ID: <20060531001322.GJ18769@moss.sous-sol.org>
References: <447173EF.9090000@shadowen.org> <exportbomb.1148291574@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <exportbomb.1148291574@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Andy Whitcroft (apw@shadowen.org) wrote:
> I think a concensus is forming that the checks for merging across
> zones were removed from the buddy allocator without anyone noticing.
> So I propose that the configuration option UNALIGNED_ZONE_BOUNDARIES
> default to on, and those architectures which have been auditied
> for alignment may turn it off.

So what's the final outcome here for -stable?  The only
relevant patch upstream appears to be Bob Picco's patch
<http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=e984bb43f7450312ba66fe0e67a99efa6be3b246>

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
