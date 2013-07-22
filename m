Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 1FD9B6B0032
	for <linux-mm@kvack.org>; Sun, 21 Jul 2013 21:31:53 -0400 (EDT)
Message-ID: <51EC8B4D.7040509@asianux.com>
Date: Mon, 22 Jul 2013 09:30:53 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: add parameter length checking for alloc_loc_track()
References: <51DF5404.4060004@asianux.com> <0000013fd3250e40-1832fd38-ede3-41af-8fe3-5a0c10f5e5ce-000000@email.amazonses.com> <51E33F98.8060201@asianux.com> <0000013fe2e73e30-817f1bdb-8dc7-4f7b-9b60-b42d5d244fda-000000@email.amazonses.com> <51E49BDF.30008@asianux.com> <0000013fed280250-85b17e35-d4d4-468d-abed-5b2e29cedb94-000000@email.amazonses.com> <51E73A16.8070406@asianux.com> <0000013ff2076fb0-b52e0245-8fb5-4842-b0dd-d812ce2c9f62-000000@email.amazonses.com> <51E882E1.4000504@gmail.com> <0000013ff73897b8-9d8f4486-1632-470c-8f1f-caf44932cef1-000000@email.amazonses.com> <20130722004255.GA13225@hacker.(null)>
In-Reply-To: <20130722004255.GA13225@hacker.(null)>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Chen Gang F T <chen.gang.flying.transformer@gmail.com>, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 07/22/2013 08:42 AM, Wanpeng Li wrote:
> On Fri, Jul 19, 2013 at 01:57:28PM +0000, Christoph Lameter wrote:
>> On Fri, 19 Jul 2013, Chen Gang F T wrote:
>>
>>> Yes, "'max' can roughly mean the same thing", but they are still a
>>> little different.
>>>
>>> 'max' also means: "the caller tells callee: I have told you the
>>> maximize buffer length, so I need not check the buffer length to be
>>> sure of no memory overflow, you need be sure of it".
>>>
>>> 'size' means: "the caller tells callee: you should use the size which I
>>> give you, I am sure it is OK, do not care about whether it can cause
>>> memory overflow or not".
>>
>> Ok that makes sense.
>>
>>> The diff may like this:
>>
>> I am fine with such a patch.
>>
>> Ultimately I would like the tracking and debugging technology to be
>> abstracted from the slub allocator and made generally useful by putting it
>> into mm/slab_common.c. SLAB has similar things but does not have all the
>> features.
> 	
> Coincidence, I am doing this work recently and will post patches soon.
> ;-)
> 

Thanks.  :-)

> Regards,
> Wanpeng Li 
> 
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
