Date: Thu, 4 Oct 2007 12:34:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [14/18] Configure stack size
In-Reply-To: <20071003.214306.41634525.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0710041231590.12221@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com> <20071004040004.936534357@sgi.com>
 <20071003213631.7a047dde@laptopd505.fenrus.org> <20071003.214306.41634525.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: arjan@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 3 Oct 2007, David Miller wrote:

> > there is still code that does DMA from and to the stack....
> > how would this work with virtual allocated stack?
> 
> That's a bug and must be fixed.
> 
> There honestly shouldn't be that many examples around.
> 
> FWIW, there are platforms using a virtually allocated kernel stack
> already.

There would be a way to address this by checking in the DMA layer for a 
virtually mapped page and then segmenting I/O at the page boundaries to 
the individual pages. We may need that anyways for large block sizes.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
