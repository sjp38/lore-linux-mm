Date: Tue, 19 Sep 2006 07:45:48 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 2/6] Introduce CONFIG_ZONE_DMA
Message-ID: <20060918224548.GA6284@localhost.usen.ad.jp>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com> <20060918183655.19679.51633.sendpatchset@schroedinger.engr.sgi.com> <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com> <20060911222739.4849.79915.sendpatchset@schroedinger.engr.sgi.com> <20060918135559.GB15096@infradead.org> <20060918152243.GA4320@localhost.na.rta> <Pine.LNX.4.64.0609181031420.19312@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060918183655.19679.51633.sendpatchset@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0609181031420.19312@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, linux-arch@vger.kernel.org, James Bottomley <James.Bottomley@SteelEye.com>, Russell King <rmk@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 18, 2006 at 10:33:00AM -0700, Christoph Lameter wrote:
> sh64 has the same strange code as parisc:
> 
> config GENERIC_ISA_DMA
>         bool
> 
> You do not have ISA_DMA so I should drop these lines?
> 
It doesn't really matter, this notation basically keeps it disabled
anyways (you'll note the absence of it from the defconfigs).

On Mon, Sep 18, 2006 at 11:36:55AM -0700, Christoph Lameter wrote:
> Index: linux-2.6.18-rc6-mm2/arch/sh/mm/init.c
> ===================================================================
> --- linux-2.6.18-rc6-mm2.orig/arch/sh/mm/init.c	2006-09-18 12:54:04.733274009 -0500
> +++ linux-2.6.18-rc6-mm2/arch/sh/mm/init.c	2006-09-18 12:58:58.563038661 -0500
> @@ -156,7 +156,6 @@ void __init paging_init(void)
>  	 * Setup some defaults for the zone sizes.. these should be safe
>  	 * regardless of distcontiguous memory or MMU settings.
>  	 */
> -	zones_size[ZONE_DMA] = 0 >> PAGE_SHIFT;
>  	zones_size[ZONE_NORMAL] = __MEMORY_SIZE >> PAGE_SHIFT;
>  #ifdef CONFIG_HIGHMEM
>  	zones_size[ZONE_HIGHMEM] = 0 >> PAGE_SHIFT;

You've missed the other ZONE_DMA references, if you scroll a bit further
down that's where we fill in ZONE_DMA, this is simply the default zone
layout that we rely on for nommu.

sh64 part looks fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
