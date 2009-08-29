Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 104CD6B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 22:01:00 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so612909qwf.44
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 19:01:00 -0700 (PDT)
Message-ID: <4A988BB4.1030005@vflare.org>
Date: Sat, 29 Aug 2009 07:30:20 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] compcache: documentation
References: <200908241008.02184.ngupta@vflare.org> <661de9470908251003y3db1fb3awb648f9340cd0beb4@mail.gmail.com> <4A94293A.2090103@vflare.org> <20090828195303.GA4889@balbir.in.ibm.com>
In-Reply-To: <20090828195303.GA4889@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On 08/29/2009 01:23 AM, Balbir Singh wrote:
> * Nitin Gupta<ngupta@vflare.org>  [2009-08-25 23:41:06]:
>
>> On 08/25/2009 10:33 PM, Balbir Singh wrote:
>>
>>
>>>> +It consists of three modules:
>>>> + - xvmalloc.ko: memory allocator
>>>
>>> I've seen your case for a custom allocator, but why can't we
>>>
>>> 1) Refactor slob and use it
>>
>> SLOB is fundamentally a different allocator. It looked at it in detail
>> but could not image how can I make it suitable for the project. SLOB
>> really does not fit it.
>>
>>> 2) Do we care about the optimizations in SLUB w.r.t. scalability in
>>> your module? If so.. will xvmalloc meet those requirements?
>>>
>>
>> Scalability is desired which xvmalloc lacks in its current state. My
>> plan is to have a wrapper around xvmalloc that creates per-cpu pools
>> and leave xvmalloc core simple. Along with this, detailed profiling
>> needs to be done to see where the bottlenecks are in the core itself.
>>
>
> I've not yet tested the patches, but adding another allocator does
> worry me a bit. Do you intend to allow other users to consume the
> allocator routines?
>

No. This allocator is not compiled as separate module, does not export any
symbol and is compiled with ramzswap. So, no one else can use it.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
