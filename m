Date: Mon, 21 May 2007 01:11:39 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] MM : alloc_large_system_hash() can free some memory for non power-of-two bucketsize
Message-ID: <20070521081139.GG19966@holomorphy.com>
References: <20070518115454.d3e32f4d.dada1@cosmosbay.com> <20070519182123.GD19966@holomorphy.com> <464F44BD.3040209@cosmosbay.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <464F44BD.3040209@cosmosbay.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III a ?crit :
>> The proper way to do this is to convert the large system hashtable
>> users to use some data structure / algorithm  other than hashing by
>> separate chaining.

On Sat, May 19, 2007 at 08:41:01PM +0200, Eric Dumazet wrote:
> No thanks. This was already discussed to death on netdev. To date, hash 
> tables are a good compromise.
> I dont mind losing part of memory, I prefer to keep good performance when 
> handling 1.000.000 or more tcp sessions.

The data structures perform well enough, but I suppose it's not worth
pushing the issue this way.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
