From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Avoiding external fragmentation with a placement policy Version 12
In-Reply-To: <429FFC21.1020108@yahoo.com.au>
Message-Id: <E1DeNiA-0008Ap-00@gondolin.me.apana.org.au>
Date: Sat, 04 Jun 2005 11:44:30 +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: mbligh@mbligh.org, davem@davemloft.net, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> network code. If the latter, that would suggest at least in theory
> it could use noncongiguous physical pages.

With Dave's latest super-TSO patch, TCP over loopback will only be
doing order-0 allocations in the common case.  UDP and others may
still do large allocations but that logic is all localised in
ip_append_data.

So if we wanted we could easily remove most large allocations over
the loopback device.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
