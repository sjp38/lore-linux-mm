Date: Thu, 11 Jul 2002 15:54:08 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
Message-ID: <20020711225408.GH25360@holomorphy.com>
References: <20810000.1026311617@baldur.austin.ibm.com> <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au> <20020710222210.GU25360@holomorphy.com> <3D2CD3D3.B43E0E1F@zip.com.au> <20020711015102.GV25360@holomorphy.com> <3D2DE264.17706BB4@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D2DE264.17706BB4@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2002 at 12:54:12PM -0700, Andrew Morton wrote:
> The problem is the access pattern.  It shouldn't be random-uniform.
> But what should it be?  random-gaussian?
> So: map a large file, access it random-gaussian.  malloc some memory,
> access it random-gaussian.  Apply eviction pressure. Measure throughput.
> Optimise throughput.
> Does this not capture what the VM is supposed to do?
> What workload is rmap supposed to be good at?

I wouldn't go through the trouble of Guassian, a step distribution,
i.e. sets A and B with P(A) = p < q = P(B), and "effective detection
of the working set" is seeing how much of the working set was retained
instead of reclaimed as p -> m(A)/m(A U B) and how much determining it
cost in terms of cpu. Or that's my first impression. The distributions
P(. | A) and P(. | B) don't matter aside from the probabilities of the
whole of A and B themselves and non-uniform creates harder to analyze
things as bits of A may well be less likely than bits of B so making
P(. | A) and P(. | B) uniform sounds easiest to me.

Throughput is probably easy to disturb in unrelated ways, but (of course)
necessary to keep track of.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
