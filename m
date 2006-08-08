Message-ID: <44D9191E.7080203@garzik.org>
Date: Tue, 08 Aug 2006 19:07:10 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193447.1396.59301.sendpatchset@lappy>
In-Reply-To: <20060808193447.1396.59301.sendpatchset@lappy>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Update the driver to make use of the netdev_alloc_skb() API and the
> NETIF_F_MEMALLOC feature.

NETIF_F_MEMALLOC does not exist in the upstream tree...  nor should it, IMO.

netdev_alloc_skb() is in the tree, and that's fine.

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
