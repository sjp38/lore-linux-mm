Date: Mon, 18 Aug 2003 14:19:16 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] prefault optimization
In-Reply-To: <3F32ECE0.1000102@us.ibm.com>
Message-ID: <Pine.LNX.4.53.0308181411380.26766@skynet>
References: <3F32ECE0.1000102@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Aug 2003, Adam Litke wrote:

> This patch attempts to reduce page fault overhead for mmap'd files.  All
> pages in the page cache that will be managed by the current vma are
> instantiated in the page table.

I believe this could punish applications which use large numbers of shared
libraries, especially if only a small portion of library code is used.
Take something like konqueror which maps over 30 shared libraries. With
prefaulting, all the libraries will be fully faulted even if only a tiny
portion of some library code is used.  This, potentially, could put a lot
of unwanted pages into the page cache which will be a kick in the pants
for low-memory systems.

For example, I don't have audio enabled at all in konqueror, but with this
patch, it will fault in 77K of data for libaudio that won't be used.

Just my 2c

-- 
Mel Gorman
http://www.csn.ul.ie/~mel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
