Date: Fri, 23 May 2008 07:36:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 13/18] hugetlb: support boot allocate different sizes
Message-ID: <20080523053641.GM13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.027712000@nick.local0.net> <20080425184041.GH9680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425184041.GH9680@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 25, 2008 at 11:40:41AM -0700, Nishanth Aravamudan wrote:
> 
> So, you made max_huge_pages an array of the same size as the hstates
> array, right?
> 
> So why can't we directly use h->max_huge_pagees everywhere, and *only*
> touch max_huge_pages in the sysctl path.

It's just to bring up the max_huge_pages array initially for the
sysctl read path. I guess the array could be built every time the
sysctl handler runs as another option... that might hide away a
bit of the ugliness into the sysctl code I suppose. I'll see how
it looks.

But remember it is a necessary ugliness due to the sysctl vector
functoins AFAIKS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
