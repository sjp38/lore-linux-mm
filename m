Date: Tue, 18 Mar 2008 16:47:07 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [7/18] Abstract out the NUMA node round robin code into a separate function
Message-ID: <20080318154707.GA23490@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015820.ECC861B41E0@basil.firstfloor.org> <20080318154209.GG23866@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080318154209.GG23866@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> hmm, I'm not seeing where next_nid gets declared locally here as it
> should have been removed in an earlier patch. Maybe it's reintroduced

No there was no earlier patch touching this, so the old next_nid 
is still there.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
