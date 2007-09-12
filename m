Date: Wed, 12 Sep 2007 15:39:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <20070821002830.GB8414@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0709121537190.4067@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com> <20070815122253.GA15268@wotan.suse.de>
 <1187183526.6114.45.camel@twins> <20070816032921.GA32197@wotan.suse.de>
 <1187581894.6114.169.camel@twins> <20070821002830.GB8414@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Nick Piggin wrote:

> The thing I don't much like about your patches is the addition of more
> of these global reserve type things in the allocators. They kind of
> suck (not your code, just the concept of them in general -- ie. including
> the PF_MEMALLOC reserve). I'd like to eventually reach a model where
> reclaimable memory from a given subsystem is always backed by enough
> resources to be able to reclaim it. What stopped you from going that
> route with the network subsystem? (too much churn, or something
> fundamental?)

That sounds very right aside from the global reserve. A given subsystem 
may exist in multiple instances and serve sub partitions of the system.
F.e. there may be a network card on node 5 and a job running on nodes 3-7
and another netwwork card on node 15 with the corresponding nodes 13-17 
doing I/O through it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
