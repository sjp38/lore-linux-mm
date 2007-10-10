Date: Tue, 9 Oct 2007 18:26:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
In-Reply-To: <200710091846.22796.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710091825470.4500@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com> <200710082255.05598.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0710091138250.32162@schroedinger.engr.sgi.com>
 <200710091846.22796.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, Andi Kleen <ak@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 9 Oct 2007, Nick Piggin wrote:

> > We already use 32k stacks on IA64. So the memory argument fail there.
> 
> I'm talking about generic code.

The stack size is set in arch code not in generic code.

> > > The solution has until now always been to fix the problems so they don't
> > > use so much stack. Maybe a bigger stack is OK for you for 1024+ CPU
> > > systems, but I don't think you'd be able to make that assumption for most
> > > normal systems.
> >
> > Yes that is why I made the stack size configurable.
> 
> Fine. I just don't see why you need this fallback.

So you would be ok with submitting the configurable stacksize patches 
separately without the fallback? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
