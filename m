From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: is_dma_zone
Date: Fri, 18 Nov 2005 01:19:00 +1100
References: <200511180059.51211.kernel@kolivas.org> <1132236943.5834.70.camel@localhost>
In-Reply-To: <1132236943.5834.70.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511180119.01250.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Nov 2005 01:15, Dave Hansen wrote:
> On Fri, 2005-11-18 at 00:59 +1100, Con Kolivas wrote:
> > +static inline int is_dma(struct zone *zone)
> > +{
> > +       return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
> > +}
>
> Any reason you can't just use 'zone_idx(z) == ZONE_DMA' here, just like
> the code you replaced?

I was just following the style of the is_highmem and is_normal immediately 
preceeding this. No strong reason otherwise.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
