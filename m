Date: Thu, 23 Oct 2008 11:47:48 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <4900A7C8.9020707@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0810231145430.19239@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221416130.26639@quilx.com>
  <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>  <1224745831.25814.21.camel@penberg-laptop>
  <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810230638450.11924@quilx.com>
  <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>
 <Pine.LNX.4.64.0810230705210.12497@quilx.com>
 <84144f020810230714g7f5d36bas812ad691140ee453@mail.gmail.com>
 <Pine.LNX.4.64.0810230721400.12497@quilx.com> <49009575.60004@cosmosbay.com>
 <Pine.LNX.4.64.0810231035510.17638@quilx.com> <4900A7C8.9020707@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Miklos Szeredi <miklos@szeredi.hu>, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008, Eric Dumazet wrote:

>> SLUB touches objects by default when allocating. And it does it immediately 
>> in slab_alloc() in order to retrieve the pointer to the next object. So 
>> there is no point of hinting there right now.
>> 
>
> Please note SLUB touches by reading object.
>
> prefetchw() gives a hint to cpu saying this cache line is going to be 
> *modified*, even
> if first access is a read. Some architectures can save some bus transactions, 
> acquiring
> the cache line in an exclusive way instead of shared one.

Most architectures actually can do that. Its probably worth to run some 
tests with that. Conversion of a cacheline from shared to exclusive can 
cost something.

>> If we go to the pointer arrays then the situation is similar to SLAB where 
>> the object is not touched by the allocator. Then the hint would be useful 
>> again.
>
> It is usefull right now for ((SLAB_DESTROY_BY_RCU | SLAB_POISON) or ctor 
> caches.

Correct.

> Probably not that important because many objects are very large anyway, and a 
> prefetchw()
> of the begining of object is partial.

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
