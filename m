Date: Sat, 19 May 2007 11:54:42 -0700 (PDT)
Message-Id: <20070519.115442.30184476.davem@davemloft.net>
Subject: Re: [PATCH] MM : alloc_large_system_hash() can free some memory
 for non power-of-two bucketsize
From: David Miller <davem@davemloft.net>
In-Reply-To: <464F3CCF.2070901@cosmosbay.com>
References: <20070518115454.d3e32f4d.dada1@cosmosbay.com>
	<20070519013724.3d4b74e0.akpm@linux-foundation.org>
	<464F3CCF.2070901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 19 May 2007 20:07:11 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: dada1@cosmosbay.com
Cc: akpm@linux-foundation.org, dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Maybe David has an idea how this can be done properly ?
> 
> ref : http://marc.info/?l=linux-netdev&m=117706074825048&w=2

You need to use __GFP_COMP or similar to make this splitting+freeing
thing work.

Otherwise the individual pages don't have page references, only
the head page of the high-order page will.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
