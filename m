Date: Wed, 12 Jan 2005 09:37:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <20050112164906.GA4935@infradead.org>
Message-ID: <Pine.LNX.4.58.0501120931460.10697@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de>
 <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com>
 <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org>
 <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
 <20050112164906.GA4935@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2005, Christoph Hellwig wrote:

> On Wed, Jan 12, 2005 at 08:39:21AM -0800, Christoph Lameter wrote:
> > The future is in higher and higher SMP counts since the chase for the
> > higher clock frequency has ended. We will increasingly see multi-core
> > cpus etc. Machines with higher CPU counts are becoming common in business.
>
> An they still are absolutely in the minority.  In fact with multicore
> cpus it becomes more and more important to be fast for SMP systtems with
> a _small_ number of CPUs, while really larget CPUs will remain a small
> nische for the forseeable future.

The benefits start to be significant pretty fast with even a few cpus
on modern architectures:

Altix  no patch:
 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  1  10    1    0.107s      6.444s   6.055s100028.084 100006.622
  1  10    2    0.121s      9.048s   4.082s 71468.414 135904.412
  1  10    4    0.129s     10.185s   3.011s 63531.985 210146.600

w/patch
 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  1  10    1    0.094s      6.116s   6.021s105517.039 105517.574
  1  10    2    0.134s      6.998s   3.087s 91879.573 169079.712
  1  10    4    0.095s      7.658s   2.043s 84519.939 268955.165

There is even a small benefit to the single thread case.

Its not the case that this patch only benefits systems with a large number
of CPUs. Of course that is when the benefits results in performance gains
by orders of magnitude.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
