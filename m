Date: Tue, 18 Mar 2008 17:45:50 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/18] Add support to allocate hugepages of different size with hugepages=...
Message-ID: <20080318164550.GF11966@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015827.15E811B41E0@basil.firstfloor.org> <20080318163225.GM23866@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080318163225.GM23866@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> hmm, it's not very clear to me how hugetlb_init_hstate() would get
> called twice for the same hstate. Should it be VM_BUG_ON() if a hstate
It is called from a __setup function and the user can specify them multiple
times.  Also when the user specified the HPAGE_SIZE already and it got set up
it should not be called again.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
