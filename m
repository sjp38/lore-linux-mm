Date: Tue, 08 Aug 2006 18:41:44 -0700 (PDT)
Message-Id: <20060808.184144.71088399.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: David Miller <davem@davemloft.net>
In-Reply-To: <44D93BEE.4000001@google.com>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	<20060808.151020.94555184.davem@davemloft.net>
	<44D93BEE.4000001@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 18:35:42 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: phillips@google.com
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> David Miller wrote:
> > I think the new atomic operation that will seemingly occur on every
> > device SKB free is unacceptable.
> 
> Alternate suggestion?

Sorry, I have none.  But you're unlikely to get your changes
considered seriously unless you can avoid any new overhead your patch
has which is of this level.

We're busy trying to make these data structures smaller, and eliminate
atomic operations, as much as possible.  Therefore anything which adds
new datastructure elements and new atomic operations will be met with
fierce resistence unless it results an equal or greater shrink of
datastructures elsewhere or removes atomic operations elsewhere in
the critical path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
