Date: Sat, 4 Sep 2004 23:04:36 -0700
From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 3/3] teach kswapd about watermarks
Message-Id: <20040904230436.1604215a.davem@davemloft.net>
In-Reply-To: <413AA879.9020105@yahoo.com.au>
References: <413AA7B2.4000907@yahoo.com.au>
	<413AA7F8.3050706@yahoo.com.au>
	<413AA841.1040003@yahoo.com.au>
	<413AA879.9020105@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If you're only doing atomic_set() and atomic_read() on kswapd_max_order,
you're not doing anything atomic on the datum so no need to make it
an atomic_t.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
