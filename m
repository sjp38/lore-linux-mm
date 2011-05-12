Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1CA06900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:00:23 -0400 (EDT)
Date: Thu, 12 May 2011 13:00:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <20110512174641.GL11579@random.random>
Message-ID: <alpine.DEB.2.00.1105121255060.28493@router.home>
References: <1305127773-10570-4-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105120942050.24560@router.home> <1305213359.2575.46.camel@mulgrave.site> <alpine.DEB.2.00.1105121024350.26013@router.home> <1305214993.2575.50.camel@mulgrave.site>
 <20110512154649.GB4559@redhat.com> <1305216023.2575.54.camel@mulgrave.site> <alpine.DEB.2.00.1105121121120.26013@router.home> <1305217843.2575.57.camel@mulgrave.site> <alpine.DEB.2.00.1105121144320.27324@router.home> <20110512174641.GL11579@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 12 May 2011, Andrea Arcangeli wrote:

> order 1 should work better, because it's less likely we end up here
> (which leaves RECLAIM_MODE_LUMPYRECLAIM on and then see what happens
> at the top of page_check_references())
>
>    else if (sc->order && priority < DEF_PRIORITY - 2)

Why is this DEF_PRIORITY - 2? Shouldnt it be DEF_PRIORITY? An accomodation
for SLAB order 1 allocs?

May I assume that the case of order 2 and 3 allocs in that case was not
very well tested after the changes to introduce compaction since people
were focusing on RHEL testing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
