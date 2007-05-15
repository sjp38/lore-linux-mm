Date: Mon, 14 May 2007 21:54:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB: Define functions for cpu slab handling instead of using
 PageActive
Message-Id: <20070514215421.d2136057.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705141959060.27789@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705141959060.27789@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007 20:00:07 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> Use inline functions to access the per cpu bit. Intoduce the notion of 
> "freezing" a slab to make things more understandable.
> 
> ...
>
> +static inline void ClearSlabFrozen(struct page *page)
> +{
> +	__ClearPageActive(page);
> +}

Non-atomic.

> -	ClearPageActive(page);

Atomic.

A substitution like this can lead to quite revoltingly subtle bugs and needs
lots of justfication.

I'll switch this back to the atomic version.  If you're really sure about
this micro-optimisation then let's do it as a standalone patch.  One which
adds a comment explaining why it is safe, and under which circumstances it
will become unsafe, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
