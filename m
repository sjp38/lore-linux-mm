Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E7621900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:09:30 -0400 (EDT)
Date: Thu, 12 May 2011 20:09:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110512180921.GP11579@random.random>
References: <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
 <20110512154649.GB4559@redhat.com>
 <1305216023.2575.54.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121121120.26013@router.home>
 <1305217843.2575.57.camel@mulgrave.site>
 <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com>
 <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
 <20110512175104.GM11579@random.random>
 <alpine.DEB.2.00.1105121302240.28493@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105121302240.28493@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 01:03:05PM -0500, Christoph Lameter wrote:
> On Thu, 12 May 2011, Andrea Arcangeli wrote:
> 
> > even order 3 is causing troubles (which doesn't immediately make lumpy
> > activated, it only activates when priority is < DEF_PRIORITY-2, so
> > after 2 loops failing to reclaim nr_to_reclaim pages), imagine what
> 
> That is a significant change for SLUB with the merge of the compaction
> code.

Even before compaction was posted, I had to shut off lumpy reclaim or
it'd hang all the time with frequent order 9 allocations. Maybe lumpy
was better before, maybe lumpy "improved" its reliability recently,
but definitely it wasn't performing well. That definitely applies to
>=2.6.32 (I had to nuke lumpy from it, and only keep compaction
enabled, pretty much like upstream with COMPACTION=y). I think I never
tried earlier lumpy code than 2.6.32, maybe it was less aggressive
back then, I don't exclude it but I thought the whole notion of lumpy
was to takedown everything in the way, which usually leads to process
hanging in swapins or pageins for frequent used memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
