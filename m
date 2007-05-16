Subject: Re: [RFC/PATCH 2/2] Make map_vm_area() static
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070516065743.GB9884@lst.de>
References: <20070516034600.8A7C6DDEE7@ozlabs.org>
	 <20070516065743.GB9884@lst.de>
Content-Type: text/plain
Date: Wed, 16 May 2007 17:54:19 +1000
Message-Id: <1179302060.32247.218.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 08:57 +0200, Christoph Hellwig wrote:
> On Wed, May 16, 2007 at 01:45:29PM +1000, Benjamin Herrenschmidt wrote:
> > map_vm_area() is only ever used inside of mm/vmalloc.c. This makes
> > it static and removes the prototype.
> 
> Looks good.

Thanks. However, patch 1/2 is the interesting one for which I'd like
to get your comment since you asked me to do it this way :-)

(I know, I incorrectly labelled it powerpc: while it's generic code)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
