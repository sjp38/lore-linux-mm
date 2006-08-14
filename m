Date: Mon, 14 Aug 2006 04:22:06 -0700 (PDT)
Message-Id: <20060814.042206.85411651.davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060814110359.GA27704@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 14 Aug 2006 15:04:03 +0400
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  	/* These elements must be at the end, see alloc_skb() for details.  */
> -	unsigned int		truesize;
> +	unsigned int		truesize, __tsize;

There is no real need for new member.

> -		kfree(skb->head);
> +		avl_free(skb->head, skb->__tsize);

Just use "skb->end - skb->head + sizeof(struct skb_shared_info)"
as the size argument.

Then, there is no reason for skb->__tsize :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
