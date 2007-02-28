Date: Wed, 28 Feb 2007 14:17:10 -0800 (PST)
Message-Id: <20070228.141710.74748180.davem@davemloft.net>
Subject: Re: [PATCH] SLUB The unqueued slab allocator V3
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070228.140022.74750199.davem@davemloft.net>
References: <Pine.LNX.4.64.0702281120110.27828@schroedinger.engr.sgi.com>
	<20070228.140022.74750199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: David Miller <davem@davemloft.net>
Date: Wed, 28 Feb 2007 14:00:22 -0800 (PST)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@engr.sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> V3 doesn't boot successfully on sparc64

False alarm!

This crash was actually due to an unrelated problem in the parport_pc
driver on my machine.

Slub v3 boots up and seems to work fine so far on sparc64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
