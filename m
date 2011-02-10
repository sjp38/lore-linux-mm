Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8D34B8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:40:03 -0500 (EST)
Date: Thu, 10 Feb 2011 19:39:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 5/5] have smaps show transparent huge pages
Message-ID: <20110210183931.GC3347@random.random>
References: <20110209195406.B9F23C9F@kernel>
 <20110209195413.6D3CB37F@kernel>
 <20110210112032.GG17873@csn.ul.ie>
 <1297350115.6737.14208.camel@nimitz>
 <20110210150942.GL17873@csn.ul.ie>
 <20110210180924.GB3347@random.random>
 <1297362032.6737.14622.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1297362032.6737.14622.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Thu, Feb 10, 2011 at 10:20:32AM -0800, Dave Hansen wrote:
> On Thu, 2011-02-10 at 19:09 +0100, Andrea Arcangeli wrote:
> > Maybe it'd be cleaner if we didn't need to cast the pmd to pte_t but I
> > guess this makes things simpler. 
> 
> Yeah, I'm not a huge fan of doing that, either.  But, I'm not sure what
> the alternatives are.  We could basically copy smaps_pte_entry() to
> smaps_pmd_entry(), and then try to make pmd variants of all of the pte
> functions and macros we call in there.

I thought at the smaps_pmd_entry possibility too, but I would expect
it to plain duplicate a bit of code just to avoid a single cast, which
is why I thought the cast was ok in this case.

> I know there's a least a bit of precedent in the hugetlbfs code for
> doing things like this, but it's not a _great_ excuse. :)

;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
