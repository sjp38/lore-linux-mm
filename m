Message-ID: <413AB023.1010404@yahoo.com.au>
Date: Sun, 05 Sep 2004 16:20:19 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/3] teach kswapd about watermarks
References: <413AA7B2.4000907@yahoo.com.au>	<413AA7F8.3050706@yahoo.com.au>	<413AA841.1040003@yahoo.com.au>	<413AA879.9020105@yahoo.com.au> <20040904230436.1604215a.davem@davemloft.net>
In-Reply-To: <20040904230436.1604215a.davem@davemloft.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:
> If you're only doing atomic_set() and atomic_read() on kswapd_max_order,
> you're not doing anything atomic on the datum so no need to make it
> an atomic_t.
> 

OK, sure. And yes, anything other than loads and stores on that
value would never be correct.

There is still the small race of two threads updating the value,
but that doesn't matter (and the atomics don't help there anyway
of course).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
