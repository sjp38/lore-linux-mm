Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA12288
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 09:09:41 -0400
Date: Tue, 6 Apr 1999 15:09:47 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.BSF.4.03.9904060124390.12767-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.05.9904061507010.437-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Chuck Lever wrote:

>math.  i'll post something about this soon.

Cool! thanks.

>i looked at doug's patch too, and it changes the "page_shift" value
>depending on the size of the hash table.  again, this *may* cause unwanted
>interactions making the hash function degenerate for certain table sizes.

Agreed.

>ref:  a stock 2.2.5 kernel
>
>p-al: a stock 2.2.5 kernel with your page struct alignment patch applied
>
>irq:  a stock 2.2.5 kernel with your irq alignment patch applied
>
>both: a stock 2.2.5 kernel with both patches applied

*snip*

>ref:    4176.4  (s=27.45)
>
>p-al:	4207.9  (s=8.1)
		   ^^^ it made _difference_
>
>irq:	4228.8  (s=11.70)
>
>both:	4207.9  (s=13.34)
		   ^^^^^ strange...

>the irq patch is a clear win over the reference kernel: it shows a

Good ;)

>consistent 1.25% improvement in overall throughput, and the performance
>difference is more than a standard deviation.  also, the variance appears
>to be less with the irq kernel.  i would bet on a more I/O bound load the
>improvement would be even more stark.
>
>i'm not certain why the combination kernel performance was worse than the
>irq-only kernel.

Hmm I'll think about that...

>"Lynch" is a PhD thesis available in postscript at Stanford's web site for
>free.  it's a study of different coloring methodologies, so it's fairly
>broad.

Thanks!! I'll search for it soon.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
