Date: Thu, 29 Aug 2002 19:45:49 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: weirdness with ->mm vs ->active_mm handling
In-Reply-To: <20020829193413.H17288@redhat.com>
Message-ID: <Pine.GSO.4.21.0208291940350.15425-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Thu, 29 Aug 2002, Benjamin LaHaise wrote:

> Hello,
> 
> In trying to track down a bug, I found routines like generic_file_read 
> getting called with current->mm == NULL.  This seems to be a valid state 
> for lazy tlb tasks, but the code throughout the kernel doesn't seem to 
> assume that.

Lazy-TLB == "promise not to use a lot of stuff in the kernel".  In particular,
any page fault in that state is a bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
