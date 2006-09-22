From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
Date: Fri, 22 Sep 2006 08:17:59 +0200
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609220817.59801.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 22 September 2006 06:02, Christoph Lameter wrote:
> We have repeatedly discussed the problems of devices having varying 
> address range requirements for doing DMA.

We already have such an API. dma_alloc_coherent(). Device drivers
are not supposed to mess with GFP_DMA* directly anymore for quite
some time. 

> We would like for the device  
> drivers to have the ability to specify exactly which address range is 
> allowed. 

I actually have my doubts it is a good idea to add that now. The devices
with weird requirements are steadily going away.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
