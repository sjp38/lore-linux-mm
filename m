Date: Wed, 01 Jun 2005 16:23:21 -0700 (PDT)
Message-Id: <20050601.162321.58454567.davem@davemloft.net>
Subject: Re: Avoiding external fragmentation with a placement policy
 Version 12
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <429E4023.2010308@yahoo.com.au>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie>
	<429E20B6.2000907@austin.ibm.com>
	<429E4023.2010308@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 02 Jun 2005 09:09:23 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> It adds a lot of complexity to the page allocator and while
> it might be very good, the only improvement we've been shown
> yet is allocating lots of MAX_ORDER allocations I think? (ie.
> not very useful)

I've been silently sitting back and considering how much this kind of
patch could help with page coloring, all existing implementations of
which fall apart due to buddy allocator fragmentation issues.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
