Date: Tue, 1 May 2007 20:57:45 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: pci hotplug patches
Message-ID: <20070502035745.GB8877@kroah.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501084841.GC14364@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070501084841.GC14364@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kristen.c.accardi@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, May 01, 2007 at 09:48:41AM +0100, Christoph Hellwig wrote:
> >  fix-gregkh-pci-pci-remove-the-broken-pci_multithread_probe-option.patch
> >  remove-pci_dac_dma_-apis.patch
> >  round_up-macro-cleanup-in-drivers-pci.patch
> >  pcie-remove-spin_lock_unlocked.patch
> >  cpqphp-partially-convert-to-use-the-kthread-api.patch
> >  ibmphp-partially-convert-to-use-the-kthreads-api.patch
> >  cpci_hotplug-partially-convert-to-use-the-kthread-api.patch
> >  msi-fix-arm-compile.patch
> >  support-pci-mcfg-space-on-intel-i915-bridges.patch
> >  pci-syscallc-switch-to-refcounting-api.patch
> > 
> > Stuff to (various levels of re-)send to Greg for the PCI tree.  I'll probably
> > drop the kthread patches as they seemed a bit half-baked and I've lost track
> > of which ones have which levels of baking.
> 
> All the partially kthread conversion were superceed with full conversion
> from me.  I've only got feedback from the cpci maintainer, and he acked
> my patch together with a simple fix from him.

Hm, I'm no longer the PCI Hotplug maintainer, so that's why I haven't
added them to my tree.  It would probably be best for everyone involved
to send them to her instead :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
