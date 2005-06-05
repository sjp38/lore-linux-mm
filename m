Date: Sun, 05 Jun 2005 12:52:49 -0700 (PDT)
Message-Id: <20050605.125249.104050648.davem@davemloft.net>
Subject: Re: Avoiding external fragmentation with a placement policy
 Version 12
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <42A10ED2.7020205@yahoo.com.au>
References: <E1DeNiA-0008Ap-00@gondolin.me.apana.org.au>
	<42A10ED2.7020205@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 04 Jun 2005 12:15:46 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: herbert@gondor.apana.org.au, mbligh@mbligh.org, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> Herbert Xu wrote:
> > With Dave's latest super-TSO patch, TCP over loopback will only be
> > doing order-0 allocations in the common case.  UDP and others may
> > still do large allocations but that logic is all localised in
> > ip_append_data.
> > 
> > So if we wanted we could easily remove most large allocations over
> > the loopback device.
> 
> I would be very interested to look into that. I would be
> willing to do benchmarks on a range of machines too if
> that would be of any use to you.

Even without the super-TSO patch, we never do larger than
PAGE_SIZE allocations for sendmsg() when the device is
scatter-gather capable (as indicated in netdev->flags).

Loopback does set this bit.

This PAGE_SIZE limit comes from net/ipv4/tcp.c:select_size().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
