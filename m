Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7903B6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 01:43:34 -0500 (EST)
Date: Tue, 23 Nov 2010 22:43:29 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101124064329.GB25170@hostway.ca>
References: <20101115195246.GB17387@hostway.ca> <20101122154419.ee0e09d2.akpm@linux-foundation.org> <20101123100402.GH19571@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101123100402.GH19571@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 10:04:03AM +0000, Mel Gorman wrote:

> On Mon, Nov 22, 2010 at 03:44:19PM -0800, Andrew Morton wrote:
> > On Mon, 15 Nov 2010 11:52:46 -0800
> > Simon Kirby <sim@hostway.ca> wrote:
> > 
> > > I noticed that CONFIG_NUMA seems to enable some more complicated
> > > reclaiming bits and figured it might help since most stock kernels seem
> > > to ship with it now.  This seems to have helped, but it may just be
> > > wishful thinking.  We still see this happening, though maybe to a lesser
> > > degree.  (The following observations are with CONFIG_NUMA enabled.)
> > > 
> 
> Hi,
> 
> As this is a NUMA machine, what is the value of
> /proc/sys/vm/zone_reclaim_mode ? When enabled, this reclaims memory
> local to the node in preference to using remote nodes. For certain
> workloads this performs better but for users that expect all of memory
> to be used, it has surprising results.
> 
> If set to 1, try testing with it set to 0 and see if it makes a
> difference. Thanks

Hi Mel,

It is set to 0.  It's an Intel EM64T...I only enabled CONFIG_NUMA since
it seemed to enable some more complicated handling, and I figured it
might help, but it didn't seem to.  It's also required for
CONFIG_COMPACTION, but that is still marked experimental.

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
