Message-ID: <44D8F919.7000006@intel.com>
Date: Tue, 08 Aug 2006 13:50:33 -0700
From: Auke Kok <auke-jan.h.kok@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193355.1396.71047.sendpatchset@lappy>
In-Reply-To: <20060808193355.1396.71047.sendpatchset@lappy>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Update the driver to make use of the NETIF_F_MEMALLOC feature.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Daniel Phillips <phillips@google.com>
> 
> ---
>  drivers/net/e1000/e1000_main.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -4020,8 +4020,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
>  		 */
>  		skb_reserve(skb, NET_IP_ALIGN);
>  
> -		skb->dev = netdev;
> -
>  		buffer_info->skb = skb;
>  		buffer_info->length = adapter->rx_buffer_len;
>  map_skb:
> @@ -4135,8 +4136,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
>  		 */
>  		skb_reserve(skb, NET_IP_ALIGN);
>  
> -		skb->dev = netdev;
> -
>  		buffer_info->skb = skb;
>  		buffer_info->length = adapter->rx_ps_bsize0;
>  		buffer_info->dma = pci_map_single(pdev, skb->data,
> -

can we really delete these??

Cheers,

Auke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
