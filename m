Date: Tue, 17 Oct 2006 17:02:36 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Reduce CONFIG_ZONE_DMA ifdefs
Message-Id: <20061017170236.35dce526.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610171123160.14002@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610171123160.14002@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Oct 2006 11:25:07 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Add a DMA_ZONE constant that can be used to avoid #ifdef DMAs. I hope this 
> will make it acceptable to remove ZONE_DMA dependent code such as the 
> bouncing logic and also allow us to deal with the GFP_DMA issues in the 
> SCSI layer.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.19-rc1-mm1/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.19-rc1-mm1.orig/include/linux/mmzone.h	2006-10-17 13:08:22.000000000 -0500
> +++ linux-2.6.19-rc1-mm1/include/linux/mmzone.h	2006-10-17 13:08:51.018160800 -0500
> @@ -149,6 +149,12 @@ enum zone_type {
>   * match the requested limits. See gfp_zone() in include/linux/gfp.h
>   */
>  
> +#ifdef CONFIG_ZONE_DMA
> +#define DMA_ZONE 1
> +#else
> +#define DMA_ZONE 0
> +#endif

This can be done in the config system.  See CONFIG_BASE_SMALL for an
example.

That would give the thing a nice name, too - say, CONFIG_HAVE_ZONE_DMA.  It
makes it obvious what's going on.

If that doesn't work out, a better name would be HAVE_ZONE_DMA or
something.  "DMA_ZONE" sounds like the number of the dma zone.


> -#ifdef CONFIG_ZONE_DMA
> -#ifdef CONFIG_ZONE_DMA
> -#ifdef CONFIG_ZONE_DMA

Only three.  Drat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
