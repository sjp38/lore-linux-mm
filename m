Date: Tue, 30 Oct 2007 11:58:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 08/10] SLUB: Optional fast path using cmpxchg_local
In-Reply-To: <20071030114933.904a4cf8.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710301155240.12746@schroedinger.engr.sgi.com>
References: <20071028033156.022983073@sgi.com> <20071028033300.240703208@sgi.com>
 <20071030114933.904a4cf8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007, Andrew Morton wrote:

> Let's cc linux-arch: presumably other architectures can implement cpu-local
> cmpxchg and would see some benefit from doing so.

Matheiu had a whole series of cmpxchg_local patches. Ccing him too. I 
think he has some numbers for other architectures.
 
> The semantics are "atomic wrt interrutps on this cpu, not atomic wrt other
> cpus", yes?

Right.

> Do you have a feel for how useful it would be for arch maintainers to implement
> this?  IOW, is it worth their time?

That depends on the efficiency of a cmpxchg_local vs. the interrupt 
enable/ disable sequence on a particular arch. On x86 this yields about 
50% so it doubles the speed of the fastpath. On other architectures the 
cmpxchg is so slow that it is not worth it (ia64 f.e.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
