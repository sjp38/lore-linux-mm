Date: Tue, 08 Aug 2006 22:53:55 -0700 (PDT)
Message-Id: <20060808.225355.78711315.davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060809054648.GD17446@2ka.mipt.ru>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060809054648.GD17446@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 Aug 2006 09:46:48 +0400
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

> There is another approach for that - do not use slab allocator for
> network dataflow at all. It automatically has all you pros amd if
> implemented correctly can have a lot of additional usefull and
> high-performance features like full zero-copy and total fragmentation
> avoidance.

Free advertisement for your network tree allocator Evgeniy? :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
