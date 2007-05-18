Date: Fri, 18 May 2007 11:15:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] increase struct page size?!
In-Reply-To: <20070518051238.GA7696@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705181114470.11881@schroedinger.engr.sgi.com>
References: <20070518040854.GA15654@wotan.suse.de> <20070517.214740.51856086.davem@davemloft.net>
 <20070518051238.GA7696@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, Nick Piggin wrote:

> The page->virtual thing is just a bonus (although have you seen what
> sort of hoops SPARSEMEM has to go through to find page_address?! It
> will definitely be a win on those architectures).

That is on the way out. See the discussion on virtual memmap support in 
sparseme.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
