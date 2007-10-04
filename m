Date: Wed, 03 Oct 2007 21:43:06 -0700 (PDT)
Message-Id: <20071003.214306.41634525.davem@davemloft.net>
Subject: Re: [14/18] Configure stack size
From: David Miller <davem@davemloft.net>
In-Reply-To: <20071003213631.7a047dde@laptopd505.fenrus.org>
References: <20071004035935.042951211@sgi.com>
	<20071004040004.936534357@sgi.com>
	<20071003213631.7a047dde@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 3 Oct 2007 21:36:31 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: arjan@infradead.org
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de, travis@sgi.com
List-ID: <linux-mm.kvack.org>

> there is still code that does DMA from and to the stack....
> how would this work with virtual allocated stack?

That's a bug and must be fixed.

There honestly shouldn't be that many examples around.

FWIW, there are platforms using a virtually allocated kernel stack
already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
