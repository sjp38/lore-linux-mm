Date: Mon, 17 Mar 2008 16:33:15 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/18] GB pages hugetlb support
Message-ID: <20080317153314.GD5578@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <1205766307.10849.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1205766307.10849.38.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> I bet copy_hugetlb_page_range() is causing your complaints.  It takes
> the dest_mm->page_table_lock followed by src_mm->page_table_lock inside
> a loop and hasn't yet been converted to call spin_lock_nested().  A
> harmless false positive.

Yes. Looking at the warning I'm not sure why lockdep doesn't filter
it out automatically. I cannot think of a legitimate case where
a "possible recursive lock" with different lock addresses would be 
a genuine bug.

So instead of a false positive, it's more like a "always false" :)

> 
> > - hugemmap04 from LTP fails. Cause unknown currently
> 
> I am not sure how well LTP is tracking mainline development in this
> area.  How do these patches do with the libhugetlbfs test suite?  We are

I wasn't aware of that one.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
