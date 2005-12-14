Date: Wed, 14 Dec 2005 08:30:28 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 1/6] Create Critical Page Pool
In-Reply-To: <439FCF4E.3090202@us.ibm.com>
Message-ID: <Pine.LNX.4.63.0512140829410.2723@cuia.boston.redhat.com>
References: <439FCECA.3060909@us.ibm.com> <439FCF4E.3090202@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.63.0512140829412.2723@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Dec 2005, Matthew Dobson wrote:

> Create the basic Critical Page Pool.  Any allocation specifying 
> __GFP_CRITICAL will, as a last resort before failing the allocation, try 
> to get a page from the critical pool.  For now, only singleton (order 0) 
> pages are supported.

How are you going to limit the number of GFP_CRITICAL
allocations to something smaller than the number of
pages in the pool ?

Unless you can do that, all guarantees are off...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
