Date: Tue, 10 Apr 2007 16:43:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
Message-Id: <20070410164307.83578b6e.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704101547290.32218@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
	<20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
	<20070410133137.e366a16b.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704101547290.32218@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007 15:49:59 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> +
> +	/*
> +	 * Verify that the number of objects is within permitted limits.
> +	 * The page->inuse field is only 16 bit wide! So we cannot have
> +	 * more than 64k objects per slab.
> +	 */
>  	if (!s->objects || s->objects > 65535)

So we _could_ use (sizeof(page->inuse) << 8).   A bit anal, I guess, but
it would provide documentation and future-proofness.  Dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
