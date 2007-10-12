Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9CJVltu015428
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 15:31:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9CJVlkp455610
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 13:31:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9CJVkbu010486
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 13:31:46 -0600
Subject: Re: [PATCH] hugetlb: Fix dynamic pool resize failure case
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071012191519.14433.13461.stgit@kernel>
References: <20071012191519.14433.13461.stgit@kernel>
Content-Type: text/plain
Date: Fri, 12 Oct 2007 12:31:45 -0700
Message-Id: <1192217505.20859.106.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-12 at 12:15 -0700, Adam Litke wrote:
> 
> Changes since V1
>         Added a comment explaining the free logic in gather_surplus_pages.
> 
> When gather_surplus_pages() fails to allocate enough huge pages to satisfy
> the requested reservation, it frees what it did allocate back to the buddy
> allocator.  put_page() should be called instead of update_and_free_page()
> to ensure that pool counters are updated as appropriate and the page's
> refcount is decremented.

The comment looks good.  It's much more obvious what it's doing now and
certainly answers all the questions I asked before.

I do think we need to consider some of the wider implications before the
series that this applies on top of goes to mainline, but this patch by
itself is just fine with me.

Acked-by: Dave Hansen <haveblue@us.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
