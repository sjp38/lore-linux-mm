From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
Date: Tue, 9 Oct 2007 19:56:30 +1000
References: <20071004035935.042951211@sgi.com> <200710091846.22796.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0710091825470.4500@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710091825470.4500@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710091956.30487.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Andi Kleen <ak@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Wednesday 10 October 2007 11:26, Christoph Lameter wrote:
> On Tue, 9 Oct 2007, Nick Piggin wrote:
> > > We already use 32k stacks on IA64. So the memory argument fail there.
> >
> > I'm talking about generic code.
>
> The stack size is set in arch code not in generic code.

Generic code must assume a 4K stack on 32-bit, in general (modulo
huge cpumasks and such, I guess).


> > > > The solution has until now always been to fix the problems so they
> > > > don't use so much stack. Maybe a bigger stack is OK for you for 1024+
> > > > CPU systems, but I don't think you'd be able to make that assumption
> > > > for most normal systems.
> > >
> > > Yes that is why I made the stack size configurable.
> >
> > Fine. I just don't see why you need this fallback.
>
> So you would be ok with submitting the configurable stacksize patches
> separately without the fallback?

Sure. It's already configurable on other architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
