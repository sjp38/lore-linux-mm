From: Andi Kleen <ak@suse.de>
Subject: Re: More thoughts on getting rid of ZONE_DMA
Date: Sat, 23 Sep 2006 02:39:57 +0200
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <200609230134.45355.ak@suse.de> <Pine.LNX.4.64.0609221715520.10484@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221715520.10484@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609230239.57694.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 23 September 2006 02:23, Christoph Lameter wrote:
> On Sat, 23 Sep 2006, Andi Kleen wrote:
> 
> > The problem is that if someone has a workload with lots of pinned pages
> > (e.g. lots of mlock) then the first 16MB might fill up completely and there 
> > is no chance at all to free it because it's pinned
> 
> Ok. That may be a problem for i386. After the removal of the GFP_DMA 
> and ZONE_DMA stuff it is then be possible to redefine ZONE_DMA (or 
> whatever we may call it ZONE_RESERVE?) to an arbitrary size a the 
> beginning of memory. Then alloc_pages_range() can dynamically decide to 
> tap that pool if necessary. 

That's should work yes. Just we need the pool.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
