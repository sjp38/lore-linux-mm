Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 42B686B0011
	for <linux-mm@kvack.org>; Sun, 15 May 2011 12:39:19 -0400 (EDT)
Date: Sun, 15 May 2011 18:39:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110515163906.GB25981@random.random>
References: <1305214993.2575.50.camel@mulgrave.site>
 <20110512154649.GB4559@redhat.com>
 <1305216023.2575.54.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121121120.26013@router.home>
 <1305217843.2575.57.camel@mulgrave.site>
 <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com>
 <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
 <alpine.DEB.2.00.1105121232110.28493@router.home>
 <20110512180018.GN11579@random.random>
 <20110513094958.GA3569@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110513094958.GA3569@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, May 13, 2011 at 10:49:58AM +0100, Mel Gorman wrote:
> On Thu, May 12, 2011 at 08:00:18PM +0200, Andrea Arcangeli wrote:
> > <SNIP>
> >
> > BTW, it comes to mind in patch 2, SLUB should clear __GFP_REPEAT too
> > (not only __GFP_NOFAIL). Clearing __GFP_WAIT may be worth it or not
> > with COMPACTION=y, definitely good idea to clear __GFP_WAIT unless
> > lumpy is restricted to __GFP_REPEAT|__GFP_NOFAIL.
> 
> This is in V2 (unreleased, testing in progress and was running
> overnight). I noticed that clearing __GFP_REPEAT is required for
> reclaim/compaction if direct reclaimers from SLUB are to return false in
> should_continue_reclaim() and bail out from high-order allocation
> properly. As it is, there is a possibility for slub high-order direct
> reclaimers to loop in reclaim/compaction for a long time. This is
> only important when CONFIG_COMPACTION=y.

Agreed. However I don't expect anyone to allocate from slub(/slab)
with __GFP_REPEAT so it's probably only theoretical but more correct
indeed ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
