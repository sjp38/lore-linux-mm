Date: Tue, 10 Jul 2007 11:38:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality,
 performance and maintenance
In-Reply-To: <20070710082709.GC16148@Krystal>
Message-ID: <Pine.LNX.4.64.0707101136290.11906@schroedinger.engr.sgi.com>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de>
 <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com>
 <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com>
 <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal>
 <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com>
 <20070709225817.GA5111@Krystal> <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com>
 <20070710082709.GC16148@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Mathieu Desnoyers wrote:

> cmpxchg_local is not available on all archs, but local_cmpxchg is. It
> expects a local_t type which is nothing else than a long. When the local
> atomic operation is not more efficient or not implemented on a given
> architecture, asm-generic/local.h falls back on atomic_long_t. If you
> want, you could work on the local_t type, which you could cast from a
> long to a pointer when you need so, since their size are, AFAIK, always
> the same (and some VM code even assume this is always the case).

It would be cleaner to have cmpxchg_local on all arches. The type 
conversion is hacky. If this is really working then we should also use the 
mechanism for other things like the vm statistics.

> The measurements I get (in cycles):
> 
>              enable interrupts (STI)   disable interrupts (CLI)   local CMPXCHG
> IA32 (P4)    112                        82                         26
> x86_64 AMD64 125                       102                         19


Looks good and seems to indicate that we can at least double the speed of 
slab allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
