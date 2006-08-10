Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060809.165846.107940575.davem@davemloft.net>
References: <44D976E6.5010106@google.com>
	 <20060809131942.GY14627@postel.suug.ch> <1155132440.12225.70.camel@twins>
	 <20060809.165846.107940575.davem@davemloft.net>
Content-Type: text/plain
Date: Thu, 10 Aug 2006 08:25:59 +0200
Message-Id: <1155191159.12225.108.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: tgraf@suug.ch, phillips@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-09 at 16:58 -0700, David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Wed, 09 Aug 2006 16:07:20 +0200
> 
> > Hmm, what does sk_buff::input_dev do? That seems to store the initial
> > device?
> 
> You can run grep on the tree just as easily as I can which is what I
> did to answer this question.  It only takes a few seconds of your
> time to grep the source tree for things like "skb->input_dev", so
> would you please do that before asking more questions like this?

That is exactly what I did, but I wanted a bit of confirmation. Sorry if
it 
offends you, but I'm a bit new to this network thing.

> It does store the initial device, but as Thomas tried so hard to
> explain to you guys these device pointers in the skb are transient and
> you cannot refer to them outside of packet receive processing.

Yes, I understood that after Thomas' last mail.

> The reason is that there is no refcounting performed on these devices
> when they are attached to the skb, for performance reasons, and thus
> the device can be downed, the module for it removed, etc. long before
> the skb is freed up.

I understood that, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
