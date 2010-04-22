Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D22746B01F1
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 12:13:16 -0400 (EDT)
Message-ID: <4BD07594.9080905@redhat.com>
Date: Thu, 22 Apr 2010 19:13:08 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com 4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
In-Reply-To: <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/22/2010 06:48 PM, Dan Magenheimer wrote:
>>> a synchronous concurrency-safe page-oriented pseudo-RAM device (such
>>>   :
>>> conform to certain policies as follows:
>>>        
>> How baked in is the synchronous requirement?  Memory, for example, can
>> be asynchronous if it is copied by a dma engine, and since there are
>> hardware encryption engines, there may be hardware compression engines
>> in the future.
>>      
> Thanks for the comment!
>
> Synchronous is required, but likely could be simulated by ensuring all
> coherency (and concurrency) requirements are met by some intermediate
> "buffering driver" -- at the cost of an extra page copy into a buffer
> and overhead of tracking the handles (poolid/inode/index) of pages in
> the buffer that are "in flight".  This is an approach we are considering
> to implement an SSD backend, but hasn't been tested yet so, ahem, the
> proof will be in the put'ing. ;-)
>    

Well, copying memory so you can use a zero-copy dma engine is 
counterproductive.

Much easier to simulate an asynchronous API with a synchronous backend.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
