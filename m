Date: Wed, 31 May 2006 10:42:07 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 0/2] Zone boundary alignment fixes, default configuration
Message-ID: <20060531174207.GA14841@kroah.com>
References: <447173EF.9090000@shadowen.org> <exportbomb.1148291574@pinky> <20060531001322.GJ18769@moss.sous-sol.org> <447D80ED.7070403@yahoo.com.au> <447D8725.4060506@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <447D8725.4060506@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Chris Wright <chrisw@sous-sol.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 31, 2006 at 01:08:05PM +0100, Andy Whitcroft wrote:
> Nick Piggin wrote:
> > Chris Wright wrote:
> > 
> >> * Andy Whitcroft (apw@shadowen.org) wrote:
> >>
> >>> I think a concensus is forming that the checks for merging across
> >>> zones were removed from the buddy allocator without anyone noticing.
> >>> So I propose that the configuration option UNALIGNED_ZONE_BOUNDARIES
> >>> default to on, and those architectures which have been auditied
> >>> for alignment may turn it off.
> >>
> >>
> >>
> >> So what's the final outcome here for -stable?  The only
> >> relevant patch upstream appears to be Bob Picco's patch
> > 
> > 
> > I think you need zone checks? [ ie. page_zone(page) == page_zone(buddy) ]
> > I had assumed Andy was going to do a patch for that.
> 
> The stack for the full optional check in -mm seems like a lot for a
> stable patch.  I think for stable we should just add the check for
> unconditionally, its very light weight and safe that way.  Am just
> putting together a patch for that now.  Will respond to this email
> shortly with that patch once its been through a few tests.

But one of the -stable rules is that it fixes a real problem that people
are having, not just a theoretical one.  Does this classify as such?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
