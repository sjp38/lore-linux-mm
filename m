Date: Tue, 08 Aug 2006 18:39:20 -0700 (PDT)
Message-Id: <20060808.183920.41636471.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: David Miller <davem@davemloft.net>
In-Reply-To: <44D93BB3.5070507@google.com>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	<20060808211731.GR14627@postel.suug.ch>
	<44D93BB3.5070507@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 18:34:43 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: phillips@google.com
Cc: tgraf@suug.ch, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Can you please characterize the conditions under which skb->dev changes
> after the alloc?  Are there writings on this subtlety?

The packet scheduler and classifier can redirect packets to different
devices, and can the netfilter layer.

The setting of skb->dev is wholly transient and you cannot rely upon
it to be the same as when you set it on allocation.

Even simple things like the bonding device change skb->dev on every
receive.

I think you need to study the networking stack a little more before
you continue to play in this delicate area :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
