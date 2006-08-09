Date: Tue, 08 Aug 2006 18:38:08 -0700 (PDT)
Message-Id: <20060808.183808.74747814.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: David Miller <davem@davemloft.net>
In-Reply-To: <44D93B60.7030507@google.com>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	<20060808135721.5af713fb@localhost.localdomain>
	<44D93B60.7030507@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 18:33:20 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: phillips@google.com
Cc: shemminger@osdl.org, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Minor rant: the whole skb_alloc familly has degenerated into an unholy
> mess and could use some rethinking.  I believe the current patch gets as
> far as three _'s at the beginning of a function, this shows it is high
> time to reroll the api.

I think it is merely an expression of how dynamic are the operations
that people want to perform on SKBs, and how important it is for
performance to implement COW semantics for the data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
