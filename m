Date: Tue, 18 Mar 2008 17:01:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [5/18] Expand the hugetlbfs sysctls to handle arrays for all hstates
Message-ID: <20080318170136.GP23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015818.E30041B41E0@basil.firstfloor.org> <20080318143438.GE23866@csn.ul.ie> <20080318164903.GG11966@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080318164903.GG11966@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (18/03/08 17:49), Andi Kleen didst pronounce:
> > Also, offhand it's not super-clear why max_huge_pages is not part of
> > hstate as we only expect one hstate per pagesize anyway.
> 
> They need to be an separate array for the sysctl parsing function.
> 

D'oh, of course. Pointing that out answers my other questions in relation to
how writing single values to a proc entry affects multiple pools as well. I
was still thinking of max_huge_pages as as a single value instead of an array.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
