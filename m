Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD9A8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 04:52:39 -0500 (EST)
Date: Thu, 24 Feb 2011 09:52:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110224095208.GP15652@csn.ul.ie>
References: <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random> <20110214022524.GA18198@sli10-conroe.sh.intel.com> <20110222142559.GD15652@csn.ul.ie> <1298438954.19589.7.camel@sli10-conroe> <20110223144509.GG31195@random.random> <1298534927.19589.41.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1298534927.19589.41.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>

On Thu, Feb 24, 2011 at 04:08:47PM +0800, Shaohua Li wrote:
> On Wed, 2011-02-23 at 22:45 +0800, Andrea Arcangeli wrote:
> > On Wed, Feb 23, 2011 at 01:29:14PM +0800, Shaohua Li wrote:
> > > Fixing it will let more people enable THP by default. but anyway we will
> > > disable it now if the issue can't be fixed.
> > 
> > Did you try what happens with transparent_hugepage=madvise? If that
> > doesn't fix it, it's min_free_kbytes issue.
> with madvise, the min_free_kbytes is still high (same as the 'always'
> case).

This high min_free_kbytes is expected and is not considered a bug as it's
related to transparent hugepages being able to allocate huge pages for a
long period of time. Essentially, it's a cost of using hugepages.

> The result is still we have about 50M memory is reserved. you can
> try at your machine with boot option 'mem=2G' and check the zoneinfo
> output.
> 

Is the actual free memory around the 50M mark or is it far higher than
it should be?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
