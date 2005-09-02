Date: Fri, 02 Sep 2005 14:57:47 -0700 (PDT)
Message-Id: <20050902.145747.66384453.davem@davemloft.net>
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4318C884.3050607@yahoo.com.au>
References: <4318C28A.5010000@yahoo.com.au>
	<20050902.143149.08652495.davem@davemloft.net>
	<4318C884.3050607@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 03 Sep 2005 07:47:48 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: ak@suse.de, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> So neither could currently supported atomic_t ops be shared with
> userland accesses?

Correct.

> Then I think it would not be breaking any interface rule to do an
> atomic_t atomic_cmpxchg either. Definitely for my usage it will
> not be shared with userland.

Ok.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
