Message-ID: <41A272BA.9000705@yahoo.com.au>
Date: Tue, 23 Nov 2004 10:14:02 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: deferred rss update instead of sloppy rss
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain> <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org> <41A26910.7090401@yahoo.com.au> <Pine.LNX.4.58.0411221436570.22895@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411221436570.22895@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 23 Nov 2004, Nick Piggin wrote:
> 
> 
>>Deferred rss might be a practical solution, but I'd prefer this if it can
>>be made workable.
> 
> 
> Both results in an additional field in task_struct that is going to be
> incremented when the page_table_lock is not held. It would be possible
> to switch to looping in procfs later. The main question with this patchset
> is:
> 

Sure.

> How and when can we get this get into the kernel?
> 

Well it is a good starting platform for the various PTL reduction patches
floating around.

I'd say Andrew could be convinced to stick it in -mm after 2.6.10, but we'd
probably need a clear path to one of the PTL patches before anything would
move into 2.6.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
