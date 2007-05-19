Date: Sat, 19 May 2007 11:21:23 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] MM : alloc_large_system_hash() can free some memory for non power-of-two bucketsize
Message-ID: <20070519182123.GD19966@holomorphy.com>
References: <20070518115454.d3e32f4d.dada1@cosmosbay.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070518115454.d3e32f4d.dada1@cosmosbay.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 11:54:54AM +0200, Eric Dumazet wrote:
> alloc_large_system_hash() is called at boot time to allocate space
> for several large hash tables.
> Lately, TCP hash table was changed and its bucketsize is not a
> power-of-two anymore.
> On most setups, alloc_large_system_hash() allocates one big page
> (order > 0) with __get_free_pages(GFP_ATOMIC, order). This single
> high_order page has a power-of-two size, bigger than the needed size.
> We can free all pages that wont be used by the hash table.
> On a 1GB i386 machine, this patch saves 128 KB of LOWMEM memory.
> TCP established hash table entries: 32768 (order: 6, 393216 bytes)

The proper way to do this is to convert the large system hashtable
users to use some data structure / algorithm  other than hashing by
separate chaining.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
