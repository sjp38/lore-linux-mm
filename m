Date: Tue, 23 Aug 2005 09:43:50 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
Message-ID: <198120000.1124815430@flay>
In-Reply-To: <Pine.LNX.4.62.0508230909120.16321@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com><Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com><Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com> <Pine.LNX.4.62.0508230909120.16321@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>, Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > The basic idea is to have a spinlock per page table entry it seems.
>> A spinlock per page table, not a spinlock per page table entry.
> 
> Thats a spinlock per pmd? Calling it per page table is a bit confusing 
> since page table may refer to the whole tree. Could you develop 
> a clearer way of referring to these locks that is not page_table_lock or 
> ptl?

Isn't that per pagetable page? Though maybe that makes less sense with
large pages.
 
M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
