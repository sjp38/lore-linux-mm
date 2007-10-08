Date: Mon, 8 Oct 2007 10:36:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
In-Reply-To: <200710071735.41386.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710081032030.26382@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com> <20071004153940.49bd5afc@bree.surriel.com>
 <Pine.LNX.4.64.0710041418100.12779@schroedinger.engr.sgi.com>
 <200710071735.41386.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, Andi Kleen <ak@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Sun, 7 Oct 2007, Nick Piggin wrote:

> > The problem can become non-rare on special low memory machines doing wild
> > swapping things though.
> 
> But only your huge systems will be using huge stacks?

I have no idea who else would be using such a feature. Relaxing the tight 
memory restrictions on stack use may allow placing larger structures on 
the stack in general.

I have some concerns about the medium NUMA systems (a few dozen of nodes) 
also running out of stack since more data is placed on the stack through 
the policy layer and since we may end up with a couple of stacked 
filesystems. Most of the current NUMA systems on x86_64 are basically 
two nodes on one motherboard. The use of NUMA controls is likely 
limited there and the complexity of the filesystems is also not high.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
