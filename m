Message-ID: <44D977D8.5070306@google.com>
Date: Tue, 08 Aug 2006 22:51:20 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193447.1396.59301.sendpatchset@lappy> <44D9191E.7080203@garzik.org>
In-Reply-To: <44D9191E.7080203@garzik.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jeff Garzik wrote:
> Peter Zijlstra wrote:
>> Update the driver to make use of the netdev_alloc_skb() API and the
>> NETIF_F_MEMALLOC feature.
> 
> NETIF_F_MEMALLOC does not exist in the upstream tree...  nor should it, 
> IMO.

Elaborate please.  Do you think that all drivers should be updated to
fix the broken blockdev semantics, making NETIF_F_MEMALLOC redundant?
If so, I trust you will help audit for it?

> netdev_alloc_skb() is in the tree, and that's fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
