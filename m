Message-ID: <42C14662.40809@shadowen.org>
Date: Tue, 28 Jun 2005 13:45:22 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [patch 2] mm: speculative get_page
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au> <42BF9D86.90204@yahoo.com.au>
In-Reply-To: <42BF9D86.90204@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

>  #define PG_free			20	/* Page is on the free lists */
> +#define PG_freeing		21	/* PG_refcount about to be freed */

Wow this needs two new page bits.  That might be a problem ongoing.
There are only 24 of these puppies and this takes us to just two
remaining.  Do we really need _two_ to track free?

One obvious area of overlap might be the PG_nosave_free which seems to
be set on free pages for software suspend.  Perhaps that and PG_free
will be equivalent in intent (though maintained differently) and allow
us to recover a bit?

There are a couple of bits which imply ownership such as PG_slab,
PG_swapcache and PG_reserved which to my mind are all exclusive.
Perhaps those plus the PG_free could be combined into a owner field.  I
am unsure if the PG_freeing can be 'backed out' if not it may also combine?

Mumble ...

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
