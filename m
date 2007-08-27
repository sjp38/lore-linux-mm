Date: Mon, 27 Aug 2007 14:43:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
In-Reply-To: <20070827143459.82bdeddd.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708271441530.8293@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
 <Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
 <20070827133347.424f83a6.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
 <20070827140440.d2109ea5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271411200.6566@schroedinger.engr.sgi.com>
 <20070827143459.82bdeddd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> > Move the check for highmem to the beginning of the function? Why 
> > should kmap_atomic fail for a non highmem page?
> 
> For test coverage, mainly.  If someone is testing highmem-enabled code on
> a 512MB machine, we want them to get told about any highmem-handling bugs,
> even though they don't have highmem.

But the test is for nested kmap_atomics. Nesting (at least allocate a 
regular page while highmem page is being mapped) needs to work in order to 
be able to allocate a page from an interrupt contexts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
