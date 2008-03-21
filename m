Message-ID: <47E366D0.6090505@cosmosbay.com>
Date: Fri, 21 Mar 2008 08:42:08 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
References: <20080321061727.491610308@sgi.com>	<47E35D73.6060703@cosmosbay.com>	<Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com> <20080321.003123.180348056.davem@davemloft.net>
In-Reply-To: <20080321.003123.180348056.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Miller a ecrit :
> From: Christoph Lameter <clameter@sgi.com>
> Date: Fri, 21 Mar 2008 00:03:51 -0700 (PDT)
> 
>> On Fri, 21 Mar 2008, Eric Dumazet wrote:
>>
>>> But, isnt it defeating the purpose of this *particular* vmalloc() use ?
>> I thought that was controlled by hashdist? I did not see it used here and 
>> so I assumed that the RR was not intended here.
> 
> It's intended for all of the major networking hash tables.

Other networking hash tables uses alloc_large_system_hash(), which handles 
hashdist settings.

But this helper is __init only, so we can not use it for ehash_locks (can be 
allocated by DCCP module)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
