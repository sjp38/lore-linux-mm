Date: Wed, 2 May 2007 11:57:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-Id: <20070502115725.683ac702.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705021137210.1027@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
	<20070501125559.9ab42896.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705021924200.24456@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705021137210.1027@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, haveblue@ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007 11:39:20 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 2 May 2007, Hugh Dickins wrote:
> 
> > I'm astonished and impressed, both with Kconfig and your use of it:
> 
> Thanks!
> 
> > I'd much rather be testing a quicklist patch:
> > I'd better give that a try.
> 
> Great. But I certainly do not mind people use SLAB. I do not think that 
> one approach should be there for all. Choice is the way to have multiple 
> allocators compete. One reason that SLAB is so crusty is because it was 
> the only solution for so long.
> 

noooo, we don't want competing slab allocators, please.  We should get slub
working well on all architectures then remove slab completely.  Having to
maintain both slab.c and slub.c would be awful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
