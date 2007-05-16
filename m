Date: Wed, 16 May 2007 08:57:43 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC/PATCH 2/2] Make map_vm_area() static
Message-ID: <20070516065743.GB9884@lst.de>
References: <20070516034600.8A7C6DDEE7@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070516034600.8A7C6DDEE7@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Wed, May 16, 2007 at 01:45:29PM +1000, Benjamin Herrenschmidt wrote:
> map_vm_area() is only ever used inside of mm/vmalloc.c. This makes
> it static and removes the prototype.

Looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
