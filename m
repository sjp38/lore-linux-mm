Date: Fri, 21 Mar 2008 00:31:23 -0700 (PDT)
Message-Id: <20080321.003123.180348056.davem@davemloft.net>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com>
References: <20080321061727.491610308@sgi.com>
	<47E35D73.6060703@cosmosbay.com>
	<Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 21 Mar 2008 00:03:51 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: dada1@cosmosbay.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Fri, 21 Mar 2008, Eric Dumazet wrote:
> 
> > But, isnt it defeating the purpose of this *particular* vmalloc() use ?
> 
> I thought that was controlled by hashdist? I did not see it used here and 
> so I assumed that the RR was not intended here.

It's intended for all of the major networking hash tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
