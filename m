Date: Tue, 19 Jun 2007 13:08:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 10/26] SLUB: Faster more efficient slab determination
 for __kmalloc.
Message-Id: <20070619130858.693ae66e.akpm@linux-foundation.org>
In-Reply-To: <20070618095915.826976488@sgi.com>
References: <20070618095838.238615343@sgi.com>
	<20070618095915.826976488@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007 02:58:48 -0700
clameter@sgi.com wrote:

> +	BUG_ON(KMALLOC_MIN_SIZE > 256 ||
> +		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));

BUILD_BUG_ON?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
