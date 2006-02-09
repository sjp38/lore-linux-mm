From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17387.33855.858274.530175@gargle.gargle.HOWL>
Date: Thu, 9 Feb 2006 21:04:47 +0300
Subject: Re: [PATCH] mm: Implement Swap Prefetching v22
In-Reply-To: <43EB43B9.5040001@yahoo.com.au>
References: <200602092339.49719.kernel@kolivas.org>
	<43EB43B9.5040001@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin writes:

[...]

 > > +/*
 > > + * We check to see no part of the vm is busy. If it is this will interrupt
 > > + * trickle_swap and wait another PREFETCH_DELAY. Purposefully racy.
 > > + */
 > > +inline void delay_swap_prefetch(void)
 > > +{
 > > +	__set_bit(0, &swapped.busy);
 > > +}
 > > +
 > 
 > Test this first so you don't bounce the cacheline around in page
 > reclaim too much.

Shouldn't we have special macros/inlines for this? Like, e.g.,

static inline void __set_bit_weak(int nr, volatile unsigned long * addr)
{
        if (!__test_bit(nr, addr))
                __set_bit(nr, addr);
}

? These test-then-set sequences start to proliferate throughout the code.

[...]

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
