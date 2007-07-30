Date: Mon, 30 Jul 2007 11:35:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/7] Generic Virtual Memmap support for SPARSEMEM
In-Reply-To: <46ADF83B.3050406@shadowen.org>
Message-ID: <Pine.LNX.4.64.0707301133350.1097@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky> <E1I9LJY-00006o-GK@hellhawk.shadowen.org>
 <20070714152058.GA12478@infradead.org> <46ADF83B.3050406@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Andy Whitcroft wrote:

> The code itself is generic in the sense its architecture neutral.  This
> is "per memory model" code.  I am wondering however why it is in an
> asm-anything include file here.  This seems to the world like it should
> be in include/linux/memory_model.h.

Riiight! Or directly in mm.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
