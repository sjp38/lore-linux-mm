From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm, for adaptive dcache hash table sizing (resend)
Date: Wed, 8 Oct 2008 03:39:39 +1100
References: <20081007064834.GA5959@wotan.suse.de> <20081007071827.GB5010@infradead.org> <18667.33351.854693.368568@harpo.it.uu.se>
In-Reply-To: <18667.33351.854693.368568@harpo.it.uu.se>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810080339.40300.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mikael Pettersson <mikpe@it.uu.se>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, netdev@vger.kernel.org, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 08 October 2008 02:37, Mikael Pettersson wrote:

> I missed the first post, but loooking at the patch it seems
> somewhat complex.

It is complex, but relatively self-contained, ie. it doesn't affect
the actual code that performs hash lookups very much (although there
can be some impact on atomicity if we have to consider something like
a full table traversal like the rt hash).


> How does this relate to traditional incremental hash tables
> like extensible hashing or linear hashing (not to be confused
> with linear probing)? In linear hashing a resize only affects
> a single collision chain at a time, and reads from other chains
> than the one being resized are unaffected.

I haven't actually seen any real implementations of those things.
AFAICS they don't exactly deal with concurrency. They are also likely
to be more costly to operate on, versus a well sized simple hash
table.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
