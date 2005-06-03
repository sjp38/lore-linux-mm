Date: Thu, 02 Jun 2005 21:49:27 -0700 (PDT)
Message-Id: <20050602.214927.59657656.davem@davemloft.net>
Subject: Re: Avoiding external fragmentation with a placement policy
 Version 12
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1117770488.5084.25.camel@npiggin-nld.site>
References: <429E50B8.1060405@yahoo.com.au>
	<429F2B26.9070509@austin.ibm.com>
	<1117770488.5084.25.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 03 Jun 2005 13:48:08 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: jschopp@austin.ibm.com, mbligh@mbligh.org, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> It would really help your cause in the short term if you can
> demonstrate improvements for say order-3 allocations (eg. use
> gige networking, TSO, jumbo frames, etc).

TSO chops up the user data into PAGE_SIZE chunks, it doesn't
make use of non-zero page orders.

AF_UNIX sockets, however, will happily use higher order
pages.  But even this is limited to SKB_MAX_ORDER which
is currently defined to 2.

So the only way to get order 3 or larger allocations with
the networking is to use jumbo frames but without TSO enabled.

Actually, even with TSO enabled, you'll get large order
allocations, but for receive packets, and these allocations
happen in software interrupt context.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
