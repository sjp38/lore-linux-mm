Date: Tue, 1 May 2007 09:48:41 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: pci hotplug patches
Message-ID: <20070501084841.GC14364@infradead.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

>  fix-gregkh-pci-pci-remove-the-broken-pci_multithread_probe-option.patch
>  remove-pci_dac_dma_-apis.patch
>  round_up-macro-cleanup-in-drivers-pci.patch
>  pcie-remove-spin_lock_unlocked.patch
>  cpqphp-partially-convert-to-use-the-kthread-api.patch
>  ibmphp-partially-convert-to-use-the-kthreads-api.patch
>  cpci_hotplug-partially-convert-to-use-the-kthread-api.patch
>  msi-fix-arm-compile.patch
>  support-pci-mcfg-space-on-intel-i915-bridges.patch
>  pci-syscallc-switch-to-refcounting-api.patch
> 
> Stuff to (various levels of re-)send to Greg for the PCI tree.  I'll probably
> drop the kthread patches as they seemed a bit half-baked and I've lost track
> of which ones have which levels of baking.

All the partially kthread conversion were superceed with full conversion
from me.  I've only got feedback from the cpci maintainer, and he acked
my patch together with a simple fix from him.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
