Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DB4FA6B0023
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:48:23 -0400 (EDT)
Date: Thu, 12 May 2011 11:48:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <1305217843.2575.57.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1105121144320.27324@router.home>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>  <1305127773-10570-4-git-send-email-mgorman@suse.de>  <alpine.DEB.2.00.1105120942050.24560@router.home>  <1305213359.2575.46.camel@mulgrave.site>  <alpine.DEB.2.00.1105121024350.26013@router.home>
  <1305214993.2575.50.camel@mulgrave.site> <20110512154649.GB4559@redhat.com>  <1305216023.2575.54.camel@mulgrave.site>  <alpine.DEB.2.00.1105121121120.26013@router.home> <1305217843.2575.57.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 12 May 2011, James Bottomley wrote:

> On Thu, 2011-05-12 at 11:27 -0500, Christoph Lameter wrote:
> > On Thu, 12 May 2011, James Bottomley wrote:
> >
> > > However, the fact remains that this seems to be a slub problem and it
> > > needs fixing.
> >
> > Why are you so fixed on slub in these matters?
>
> Because, as has been hashed out in the thread, changing SLUB to SLAB
> makes the hang go away.

SLUB doesnt hang here with earlier kernel versions either. So the higher
allocations are no longer as effective as they were before. This is due to
a change in another subsystem.

> >  Its an key component but
> > there is a high interaction with other subsystems. There was no recent
> > change in slub that changed the order of allocations. There were changes
> > affecting the reclaim logic. Slub has been working just fine with the
> > existing allocation schemes for a long time.
>
> So suggest an alternative root cause and a test to expose it.

Have a look at my other emails? I am just repeating myself again it seems.

Try order = 1 which gives you SLAB like interaction with the page
allocator. Then we at least know that it is the order 2 and 3 allocs that
are the problem and not something else.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
