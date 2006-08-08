Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <44D8F919.7000006@intel.com>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	 <20060808193355.1396.71047.sendpatchset@lappy> <44D8F919.7000006@intel.com>
Content-Type: text/plain
Date: Tue, 08 Aug 2006 22:59:14 +0200
Message-Id: <1155070755.23134.26.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Auke Kok <auke-jan.h.kok@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-08 at 13:50 -0700, Auke Kok wrote:
> Peter Zijlstra wrote:
> > Update the driver to make use of the NETIF_F_MEMALLOC feature.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Signed-off-by: Daniel Phillips <phillips@google.com>
> > 
> > ---
> >  drivers/net/e1000/e1000_main.c |   11 +++++------
> >  1 file changed, 5 insertions(+), 6 deletions(-)
> > 
> > Index: linux-2.6/drivers/net/e1000/e1000_main.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> > +++ linux-2.6/drivers/net/e1000/e1000_main.c
> > @@ -4020,8 +4020,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
> >  		 */
> >  		skb_reserve(skb, NET_IP_ALIGN);
> >  
> > -		skb->dev = netdev;
> > -
> >  		buffer_info->skb = skb;
> >  		buffer_info->length = adapter->rx_buffer_len;
> >  map_skb:
> > @@ -4135,8 +4136,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
> >  		 */
> >  		skb_reserve(skb, NET_IP_ALIGN);
> >  
> > -		skb->dev = netdev;
> > -
> >  		buffer_info->skb = skb;
> >  		buffer_info->length = adapter->rx_ps_bsize0;
> >  		buffer_info->dma = pci_map_single(pdev, skb->data,
> > -
> 
> can we really delete these??

The new {,__}netdev_alloc_skb() will set it when the allocation
succeeds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
