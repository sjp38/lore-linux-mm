From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [git pull] SLUB updates for 2.6.25
Date: Tue, 5 Feb 2008 11:05:11 +1100
References: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com> <200802051010.49372.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802041542570.4774@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802041542570.4774@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802051105.12194.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, willy@linux.intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 05 February 2008 10:47, Christoph Lameter wrote:
> On Tue, 5 Feb 2008, Nick Piggin wrote:
> > > erk, sorry, I misremembered.   I was about to merge all the patches we
> > > weren't going to merge.  oops.
> >
> > While you're there, can you drop the patch(es?) I commented on
> > and didn't get an answer to. Like the ones that open code their
> > own locking primitives and do risky looking things with barriers
> > to boot...
>
> That patch will be moved to a special archive for
> microbenchmarks. It shows the same issues like the __unlock patch.

Ok. But the approach is just not so good. If you _really_ need something
like that and it is a win over the regular non-atomic unlock, then you
just have to implement it as a generic locking / atomic operation and
allow all architectures to implement the optimal (and correct) memory
barriers.

Anyway....


> > Also, WRT this one:
> > slub-use-non-atomic-bit-unlock.patch
> >
> > This is strange that it is unwanted. Avoiding atomic operations
> > is a pretty good idea. The fact that it appears to be slower on
> > some microbenchmark on some architecture IMO either means that
> > their __clear_bit_unlock or the CPU isn't implemented so well...
>
> Its slower on x86_64 and that is a pretty important arch. So
> I am to defer this until we have analyzed the situation some more. Could
> there be some effect of atomic ops on the speed with which a cacheline is
> released?

I'm sure it could have an effect. But why is the common case in SLUB
for the cacheline to be bouncing? What's the benchmark? What does SLAB
do in that benchmark, is it faster than SLUB there? What does the
non-atomic bit unlock do to Willy's database workload?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
