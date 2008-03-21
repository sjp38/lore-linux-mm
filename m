Date: Fri, 21 Mar 2008 00:31:00 -0700 (PDT)
Message-Id: <20080321.003100.155729406.davem@davemloft.net>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
From: David Miller <davem@davemloft.net>
In-Reply-To: <47E35D73.6060703@cosmosbay.com>
References: <20080321061703.921169367@sgi.com>
	<20080321061727.491610308@sgi.com>
	<47E35D73.6060703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Mar 2008 08:02:11 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: dada1@cosmosbay.com
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> But, isnt it defeating the purpose of this *particular* vmalloc() use ?
> 
> CONFIG_NUMA and vmalloc() at boot time means :
> 
> Try to distribute the pages on several nodes.
> 
> Memory pressure on ehash_locks[] is so high we definitly want to spread it.
> 
> (for similar uses of vmalloc(), see also hashdist=1 )
> 
> Also, please CC netdev for network patches :)

I agree with Eric, converting any of the networking hash
allocations to this new facility is not the right thing
to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
