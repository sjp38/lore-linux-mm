Date: Wed, 21 Mar 2007 16:00:51 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated helper macros.
Message-ID: <20070321160051.GA5264@infradead.org>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <20070319200513.17168.52238.stgit@localhost.localdomain> <4600B216.3010505@yahoo.com.au> <1174490261.21684.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1174490261.21684.13.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 21, 2007 at 10:17:40AM -0500, Adam Litke wrote:
> > Also, it is going to be hugepage-only, isn't it? So should the naming be
> > changed to reflect that? And #ifdef it...
> 
> They are doing some interesting things on Cell that could take advantage
> of this.

That would be new to me.  What we need on Cell is fixing up the
get_unmapped_area mess which Ben is working on now.

And let me once again repeat that I don't like this at all.  I'll
rather have a few ugly ifdefs in strategic places than a big object
oriented mess like this with just a single user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
