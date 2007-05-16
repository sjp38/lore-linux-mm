Subject: Re: [RFC/PATCH 1/2] powerpc: unmap_vm_area becomes
	unmap_kernel_range
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070516034600.18427DDEE4@ozlabs.org>
References: <20070516034600.18427DDEE4@ozlabs.org>
Content-Type: text/plain
Date: Wed, 16 May 2007 13:48:37 +1000
Message-Id: <1179287317.32247.207.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 13:45 +1000, Benjamin Herrenschmidt wrote:
> This patch renames unmap_vm_area to unmap_kernel_range and make
> it take an explicit range instead of a vm_area struct. This makes
> it more versatile for code that wants to play with kernel page
> tables outside of the standard vmalloc area.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org> 

BTW, sorry for the incorrect title, it's not powerpc specific really
(though I want to use the new function from powerpc code)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
