Date: Wed, 09 Aug 2006 16:58:46 -0700 (PDT)
Message-Id: <20060809.165846.107940575.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: David Miller <davem@davemloft.net>
In-Reply-To: <1155132440.12225.70.camel@twins>
References: <44D976E6.5010106@google.com>
	<20060809131942.GY14627@postel.suug.ch>
	<1155132440.12225.70.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 09 Aug 2006 16:07:20 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: tgraf@suug.ch, phillips@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Hmm, what does sk_buff::input_dev do? That seems to store the initial
> device?

You can run grep on the tree just as easily as I can which is what I
did to answer this question.  It only takes a few seconds of your
time to grep the source tree for things like "skb->input_dev", so
would you please do that before asking more questions like this?

It does store the initial device, but as Thomas tried so hard to
explain to you guys these device pointers in the skb are transient and
you cannot refer to them outside of packet receive processing.

The reason is that there is no refcounting performed on these devices
when they are attached to the skb, for performance reasons, and thus
the device can be downed, the module for it removed, etc. long before
the skb is freed up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
