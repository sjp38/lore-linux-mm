Message-ID: <44D976E6.5010106@google.com>
Date: Tue, 08 Aug 2006 22:47:18 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
References: <20060808193345.1396.16773.sendpatchset@lappy>	<20060808211731.GR14627@postel.suug.ch>	<44D93BB3.5070507@google.com> <20060808.183920.41636471.davem@davemloft.net>
In-Reply-To: <20060808.183920.41636471.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: tgraf@suug.ch, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> From: Daniel Phillips <phillips@google.com>
  >>Can you please characterize the conditions under which skb->dev changes
>>after the alloc?  Are there writings on this subtlety?
> 
> The packet scheduler and classifier can redirect packets to different
> devices, and can the netfilter layer.
> 
> The setting of skb->dev is wholly transient and you cannot rely upon
> it to be the same as when you set it on allocation.
>
> Even simple things like the bonding device change skb->dev on every
> receive.

Thankyou, this is easily fixed.

> I think you need to study the networking stack a little more before
> you continue to play in this delicate area :-)

The VM deadlock is also delicate.  Perhaps we can work together.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
