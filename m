Message-ID: <448A762F.7000105@yahoo.com.au>
Date: Sat, 10 Jun 2006 17:35:11 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of	physical
 pages backing it
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
In-Reply-To: <1149903235.31417.84.camel@galaxy.corp.google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit Seth wrote:
> Below is a patch that adds number of physical pages that each vma is
> using in a process.  Exporting this information to user space
> using /proc/<pid>/maps interface.
> 
> There is currently /proc/<pid>/smaps that prints the detailed
> information about the usage of physical pages but that is a very
> expensive operation as it traverses all the PTs (for some one who is
> just interested in getting that data for each vma).

Yet more cacheline footprint in the page fault and unmap paths...

What is this used for and why do we want it? Could you do some
smaps-like interface that can work on ranges of memory, and
continue to walk pagetables instead?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
