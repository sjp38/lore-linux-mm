Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060809161816.GA14627@postel.suug.ch>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	 <20060808211731.GR14627@postel.suug.ch> <44D93BB3.5070507@google.com>
	 <20060808.183920.41636471.davem@davemloft.net>
	 <44D976E6.5010106@google.com> <20060809131942.GY14627@postel.suug.ch>
	 <1155132440.12225.70.camel@twins>  <20060809161816.GA14627@postel.suug.ch>
Content-Type: text/plain
Date: Wed, 09 Aug 2006 18:19:54 +0200
Message-Id: <1155140394.12225.88.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Graf <tgraf@suug.ch>
Cc: Daniel Phillips <phillips@google.com>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-09 at 18:18 +0200, Thomas Graf wrote:
> * Peter Zijlstra <a.p.zijlstra@chello.nl> 2006-08-09 16:07
> > I think Daniel was thinking of adding struct net_device *
> > sk_buff::alloc_dev,
> > I know I was after reading the first few mails. However if adding a
> > field 
> > there is strict no-no....
> > 
> > /me takes a look at struct sk_buff
> > 
> > Hmm, what does sk_buff::input_dev do? That seems to store the initial
> > device?
> 
> No, skb->input_dev is used when redirecting packets around in the
> stack and may change. Even if it would keep its value the reference
> to the netdevice is not valid anymore when you free the skb as the
> skb was queued and the refcnt acquired in __netifx_rx_schedule()
> has been released again thus making it possible for the netdevice
> to disappear.

Bah, tricky stuff that.

disregards this part from -v2 then :-(


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
