Date: Fri, 18 Aug 2006 01:51:23 -0700 (PDT)
Message-Id: <20060818.015123.104036098.davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
From: David Miller <davem@davemloft.net>
In-Reply-To: <200608181129.15075.ak@suse.de>
References: <20060816142557.acccdfcf.ak@suse.de>
	<Pine.LNX.4.64.0608171920220.28680@schroedinger.engr.sgi.com>
	<200608181129.15075.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andi Kleen <ak@suse.de>
Date: Fri, 18 Aug 2006 11:29:14 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: clameter@sgi.com, hch@infradead.org, johnpol@2ka.mipt.ru, arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> So ideal would be something dynamic to turn on/off io placement, maybe based 
> on node_distance() again, with the threshold tweakable per architecture?

We have this ugly 'hashdist' thing, let's remove the __initdata tag
on it, give it a useful name, and let architectures set it as
they deem appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
