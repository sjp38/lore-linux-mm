Date: Wed, 16 Aug 2006 02:40:08 -0700 (PDT)
Message-Id: <20060816.024008.74744877.davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060816093837.GA11096@infradead.org>
References: <20060816091029.GA6375@infradead.org>
	<20060816093159.GA31882@2ka.mipt.ru>
	<20060816093837.GA11096@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 16 Aug 2006 10:38:37 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: hch@infradead.org
Cc: johnpol@2ka.mipt.ru, arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> We could, but I'd rather waste 4 bytes in struct net_device than
> having such ugly warts in common code.

Why not instead have struct device store some default node value?
The node decision will be sub-optimal on non-pci but it won't crash.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
