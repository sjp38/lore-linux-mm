Date: Tue, 18 Mar 2008 17:49:03 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [5/18] Expand the hugetlbfs sysctls to handle arrays for all hstates
Message-ID: <20080318164903.GG11966@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015818.E30041B41E0@basil.firstfloor.org> <20080318143438.GE23866@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080318143438.GE23866@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> Also, offhand it's not super-clear why max_huge_pages is not part of
> hstate as we only expect one hstate per pagesize anyway.

They need to be an separate array for the sysctl parsing function.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
