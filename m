Date: Sun, 28 Oct 2007 15:07:43 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 01/10] SLUB: Consolidate add_partial and add_partial_tail
 to one function
In-Reply-To: <20071028033258.546533164@sgi.com>
Message-ID: <Pine.LNX.4.64.0710281506400.6766@sbz-30.cs.Helsinki.FI>
References: <20071028033156.022983073@sgi.com> <20071028033258.546533164@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Oct 2007, Christoph Lameter wrote:
> Add a parameter to add_partial instead of having separate functions.
> That allows the detailed control from multiple places when putting
> slabs back to the partial list. If we put slabs back to the front
> then they are likely immediately used for allocations. If they are
> put at the end then we can maximize the time that the partial slabs
> spent without allocations.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
