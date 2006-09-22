Date: Fri, 22 Sep 2006 09:35:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
In-Reply-To: <200609220817.59801.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0609220934040.7083@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com>
 <200609220817.59801.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Martin Bligh <mbligh@mbligh.org>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2006, Andi Kleen wrote:

> On Friday 22 September 2006 06:02, Christoph Lameter wrote:
> > We have repeatedly discussed the problems of devices having varying 
> > address range requirements for doing DMA.
> 
> We already have such an API. dma_alloc_coherent(). Device drivers
> are not supposed to mess with GFP_DMA* directly anymore for quite
> some time. 

Device drivers need to be able to indicate ranges of addresses that may be 
different from ZONE_DMA. This is an attempt to come up with a future 
scheme that does no longer rely on device drivers referring to zoies.

> > We would like for the device  
> > drivers to have the ability to specify exactly which address range is 
> > allowed. 
> 
> I actually have my doubts it is a good idea to add that now. The devices
> with weird requirements are steadily going away

Hmm.... Martin?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
