Date: Wed, 30 Jan 2008 11:08:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <20080130180207.GU26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801301104080.27491@schroedinger.engr.sgi.com>
References: <20080130022909.677301714@sgi.com> <20080130022944.236370194@sgi.com>
 <20080130180207.GU26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008, Robin Holt wrote:

> Index: git-linus/mm/mmu_notifier.c
> ===================================================================
> --- git-linus.orig/mm/mmu_notifier.c	2008-01-30 11:43:45.000000000 -0600
> +++ git-linus/mm/mmu_notifier.c	2008-01-30 11:56:08.000000000 -0600
> @@ -99,3 +99,8 @@ void mmu_rmap_notifier_unregister(struct
>  }
>  EXPORT_SYMBOL(mmu_rmap_notifier_unregister);
>  
> +void mmu_rmap_export_page(struct page *page)
> +{
> +	SetPageExternalRmap(page);
> +}
> +EXPORT_SYMBOL(mmu_rmap_export_page);

Then mmu_rmap_export_page would have to be called before the subsystem 
establishes the rmap entry for the page. Could we do all PageExternalRmap 
modifications under Pagelock?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
