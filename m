Date: Tue, 9 Nov 2004 18:56:40 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-Id: <20041109185640.32c8871b.akpm@osdl.org>
In-Reply-To: <419181D5.1090308@cyberone.com.au>
References: <20041109164642.GE7632@logos.cnet>
	<20041109121945.7f35d104.akpm@osdl.org>
	<20041109174125.GF7632@logos.cnet>
	<20041109133343.0b34896d.akpm@osdl.org>
	<20041109182622.GA8300@logos.cnet>
	<20041109142257.1d1411e1.akpm@osdl.org>
	<4191675B.3090903@cyberone.com.au>
	<419181D5.1090308@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> Shall we crank up min_free_kbytes a bit?

May as well.  or we could do something fancy in register_netdevice().

>  We could also compress the watermarks, while increasing pages_min? That
>  will increase the GFP_ATOMIC buffer as well, without having free memory
>  run away on us (eg pages_min = 2*x, pages_low = 5*x/2, pages_high = 3*x)?

There are also hidden intermediate levels for rt-policy tasks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
