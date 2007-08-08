Date: Wed, 8 Aug 2007 11:46:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
Message-Id: <20070808114636.7c6f26ab.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708081050590.12652@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>
	<20070806103658.603735000@chello.nl>
	<Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
	<20070808014435.GG30556@waste.org>
	<Pine.LNX.4.64.0708081004290.12652@schroedinger.engr.sgi.com>
	<20070808103946.4cece16c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708081050590.12652@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007 10:57:13 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> I think in general irq context reclaim is doable. Cannot see obvious 
> issues on a first superficial pass through rmap.c. The irq holdoff would 
> be pretty long though which may make it unacceptable.

The IRQ holdoff could be tremendous.  But if it is sufficiently infrequent
and if the worst effect is merely a network rx ring overflow then the tradeoff
might be a good one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
