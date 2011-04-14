Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EE7DA900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 12:57:24 -0400 (EDT)
Date: Thu, 14 Apr 2011 17:57:14 +0100
From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
Message-ID: <20110414165714.GR2268@decadent.org.uk>
References: <1300772711.26693.473.camel@localhost>
 <alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
 <20110414144807.19ec5f69@notabene.brown>
 <20110414142954.GB15707@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110414142954.GB15707@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: NeilBrown <neilb@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, Apr 14, 2011 at 04:29:54PM +0200, Andrea Arcangeli wrote:
> On Thu, Apr 14, 2011 at 02:48:07PM +1000, Neil Brown wrote:
> > I think the x86 version returns 0 or -1 (that is from reading the code and
> > using google to check what 'sbb' does).
> 
> It really returns -1...
> 
Sorry, thought I checked this before sending the patch.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
