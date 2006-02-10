From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: Implement Swap Prefetching v22
Date: Fri, 10 Feb 2006 11:08:46 +1100
References: <200602092339.49719.kernel@kolivas.org> <43EB43B9.5040001@yahoo.com.au> <17387.33855.858274.530175@gargle.gargle.HOWL>
In-Reply-To: <17387.33855.858274.530175@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602101108.47614.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Friday 10 February 2006 05:04, Nikita Danilov wrote:
> Nick Piggin writes:
>
> [...]
>
>  > > +/*
>  > > + * We check to see no part of the vm is busy. If it is this will
>  > > interrupt + * trickle_swap and wait another PREFETCH_DELAY.
>  > > Purposefully racy. + */
>  > > +inline void delay_swap_prefetch(void)
>  > > +{
>  > > +	__set_bit(0, &swapped.busy);
>  > > +}
>  > > +
>  >
>  > Test this first so you don't bounce the cacheline around in page
>  > reclaim too much.
>
> Shouldn't we have special macros/inlines for this? Like, e.g.,
>
> static inline void __set_bit_weak(int nr, volatile unsigned long * addr)
> {
>         if (!__test_bit(nr, addr))
>                 __set_bit(nr, addr);
> }
>
> ? These test-then-set sequences start to proliferate throughout the code.

Maybe.

There isn't actually a non-atomic __test_bit anyway, only a test_bit. The 
non-atomic __test_and_set_bit already exists, but that sets the bit 
regardless of what the bit was as far as I can tell.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
