Message-ID: <44E0B61F.3000706@hp.com>
Date: Mon, 14 Aug 2006 10:42:55 -0700
From: Rick Jones <rick.jones2@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] network memory allocator.
References: <20060814110359.GA27704@2ka.mipt.ru>	<9286.1155557268@ocs10w.ocs.com.au> <20060814122049.GC18321@2ka.mipt.ru>
In-Reply-To: <20060814122049.GC18321@2ka.mipt.ru>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Keith Owens <kaos@ocs.com.au>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Evgeniy Polyakov wrote:
> On Mon, Aug 14, 2006 at 10:07:48PM +1000, Keith Owens (kaos@ocs.com.au) wrote:
> 
>>Evgeniy Polyakov (on Mon, 14 Aug 2006 15:04:03 +0400) wrote:
>>
>>>Network tree allocator can be used to allocate memory for all network
>>>operations from any context....
>>>...
>>>Design of allocator allows to map all node's pages into userspace thus
>>>allows to have true zero-copy support for both sending and receiving
>>>dataflows.
>>
>>Is that true for architectures with virtually indexed caches?  How do
>>you avoid the cache aliasing problems?
> 
> 
> Pages are preallocated and stolen from main memory allocator, what is
> the problem with that caches? Userspace can provide enough offset so
> that pages would not create aliases - it is usuall mmap.

That may depend heavily on the architecture.  PA-RISC has the concept of 
spaceid's, and bits from the spaceid can be included in the hash along 
with bits from the offset.  So, it is not possible to simply match the 
offset, one has to make sure that hash bits from the spaceid hash the 
same as well.

Now, PA-RISC CPUs have the ability to disable spaceid hashing, and it is 
entirely possible that the PA-RISC linux port does that, but I thought I 
would mention it as an example.  I'm sure the "official" PA-RISC linux 
folks can expand on that much much better than I can.

rick jones

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
