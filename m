Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 61A736B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 22:38:08 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1997237pad.5
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 19:38:08 -0700 (PDT)
Message-ID: <525F4D4C.2090002@asianux.com>
Date: Thu, 17 Oct 2013 10:37:00 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/readahead.c: need always return 0 when system call
 readahead() succeeds
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com> <525CF787.6050107@asianux.com> <alpine.DEB.2.02.1310161603280.2417@chino.kir.corp.google.com> <525F35F7.4070202@asianux.com> <alpine.DEB.2.02.1310161812480.12062@chino.kir.corp.google.com> <525F3E39.3060603@asianux.com> <alpine.DEB.2.02.1310161918260.21167@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1310161918260.21167@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On 10/17/2013 10:21 AM, David Rientjes wrote:
> On Thu, 17 Oct 2013, Chen Gang wrote:
> 
>>> I think your patches should be acked before being merged into linux-next, 
>>> Hugh just had to revert another one that did affect Linus's tree in 
>>> 1ecfd533f4c5 ("mm/mremap.c: call pud_free() after fail calling
>>> pmd_alloc()").  I had to revert your entire series of mpol_to_str() 
>>> changes in -mm.  It's getting ridiculous and a waste of other people's 
>>> time.
>>>
>>
>> If always get no reply, what to do, next?
>>
> 
> If nobody ever acks your patches, they probably aren't that important.  At 
> the very least, something that nobody has looked at shouldn't be included 
> if it's going to introduce a regression.
> 

At least, that is not quite polite.

And when get conclusion, please based on the proofs: "is it necessary to
list them to check whether they are 'important' or not"?


>> But all together, I welcome you to help ack/nack my patches for mm
>> sub-system (although I don't know your ack/nack whether have effect or not).
>>
> 
> If it touches mm, then there is someone on this list who can ack it and 
> you can cc them by looking at the output of scripts/get_maintainer.pl.  If 
> nobody is interested in it, or if it doesn't do anything important, nobody 
> is going to spend their time reviewing it.
> 

Of cause, every time, I send patch according to "scripts/get_maintainer.pl".

So again: "is it necessary to list them to check whether they are
'important' or not?"


> I'm not going to continue this thread, the patch in question has been 
> removed from -mm so I have no further interest in discussing it.
> 
> 

OK, end discussing if you no reply.

Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
