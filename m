Date: Tue, 18 Mar 2008 16:04:23 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [7/18] Abstract out the NUMA node round robin code into a separate function
Message-ID: <20080318160423.GJ23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015820.ECC861B41E0@basil.firstfloor.org> <20080318154209.GG23866@csn.ul.ie> <20080318154707.GA23490@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080318154707.GA23490@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (18/03/08 16:47), Andi Kleen didst pronounce:
> > hmm, I'm not seeing where next_nid gets declared locally here as it
> > should have been removed in an earlier patch. Maybe it's reintroduced
> 
> No there was no earlier patch touching this, so the old next_nid 
> is still there.
> 

ah yes, my bad. I thought it went away in patch 1/18.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
