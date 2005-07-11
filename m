Subject: Re: [PATCH] Early kmalloc/kfree
From: Alex Williamson <alex.williamson@hp.com>
In-Reply-To: <Pine.LNX.4.62.0507091801170.22975@graphe.net>
References: <20050708203807.GG27544@localhost.localdomain.suse.lists.linux.kernel>
	 <p73zmsxncym.fsf@verdi.suse.de>
	 <Pine.LNX.4.62.0507091801170.22975@graphe.net>
Content-Type: text/plain
Date: Mon, 11 Jul 2005 09:41:17 -0600
Message-Id: <1121096477.28557.60.camel@tdi>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Andi Kleen <ak@suse.de>, Bob Picco <bob.picco@hp.com>, linux-mm@kvack.org, manfred@colorfullife.com, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Sat, 2005-07-09 at 18:06 -0700, Christoph Lameter wrote:
> On Fri, 9 Jul 2005, Andi Kleen wrote:
> 
> > I think that is a really really bad idea.   slab is already complex enough
> > and adding scary hacks like this will probably make it collapse
> > under its own weight at some point.
> 
> Seconded.
> 
> Maybe we can solve this by bringing the system up in a limited 
> configuration and then discover additional capabilities during ACPI 
> discovery and reconfigure.

   From a user perspective of the memory allocators, I liked this idea
of making the transition from bootmem to slab be transparent.  It's
currently extremely difficult to have any kind of service span the
transition when there doesn't even appear to be a programmatic way to
know which one to use. 

   The original problem Bob and I were trying to solve is simply how to
automatically deal with a system that may or may not have an IOMMU that
if it exists, is only discoverable in ACPI namespace.  Getting ACPI
namespace available by paginig_init() makes this relatively easy because
the memory zones can be setup properly for the hardware available.  If
we wait till after that point, we'll need to figure out how to
re-balance the dma and normal zones to make memory allocations
efficient.

   I agree that ACPI is potentially a slippery slope, and many pieces of
it are impractical for early use.  I think this can be controlled by
using common early setup services in the ACPI subsystem that limit what
components get initialized.  That said, I'm open to other suggestions on
how we might reconfigure the system later to accomplish this task.
Thanks,

	Alex


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
