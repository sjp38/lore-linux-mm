Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBCB6B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:59:16 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n5so14923464wmn.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:59:16 -0800 (PST)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id vx5si6885535wjc.219.2016.01.26.23.59.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 23:59:15 -0800 (PST)
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 27 Jan 2016 07:59:14 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 09F1A17D805D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 07:59:21 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0R7xCLp1245538
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 07:59:12 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0R7xBHt031291
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 00:59:12 -0700
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
 <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com>
 <20160126181903.GB4671@osiris>
 <alpine.DEB.2.10.1601261525580.25141@chino.kir.corp.google.com>
 <20160127001918.GA7089@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1601261633520.6121@chino.kir.corp.google.com>
 <20160127005920.GB7089@js1304-P5Q-DELUXE>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56A878CF.7090507@de.ibm.com>
Date: Wed, 27 Jan 2016 08:59:11 +0100
MIME-Version: 1.0
In-Reply-To: <20160127005920.GB7089@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On 01/27/2016 01:59 AM, Joonsoo Kim wrote:
> On Tue, Jan 26, 2016 at 04:36:11PM -0800, David Rientjes wrote:
>> On Wed, 27 Jan 2016, Joonsoo Kim wrote:
>>
>>>> I'd agree if CONFIG_DEBUG_PAGEALLOC only did anything when 
>>>> debug_pagealloc_enabled() is true, but that doesn't seem to be the case.  
>>>> When CONFIG_DEBUG_SLAB is enabled, for instance, CONFIG_DEBUG_PAGEALLOC 
>>>> also enables stackinfo storing and poisoning and it's not guarded by 
>>>> debug_pagealloc_enabled().
>>>>
>>>> It seems like CONFIG_DEBUG_PAGEALLOC enables debugging functionality 
>>>> outside the scope of the debug_pagealloc=on kernel parameter, so 
>>>> DEBUG_PAGEALLOC(disabled) actually does mean something.
>>>
>>> Hello, David.
>>>
>>> I tried to fix CONFIG_DEBUG_SLAB case on 04/16 of following patchset.
>>>
>>> http://thread.gmane.org/gmane.linux.kernel.mm/144527
>>>
>>> I found that there are more sites to fix but not so many.
>>> We can do it.
>>>
>>
>> For the slab case, sure, this can be fixed, but there is other code that 
>> uses CONFIG_DEBUG_PAGEALLOC to suggest debugging is always enabled and is 
>> indifferent to debug_pagealloc_enabled().  I find this in powerpc and 
>> sparc arch code as well as generic vmalloc code.  
> 
> Yes, I also found it.
> 
>>
>> If we can convert existing users that only check for 
>> CONFIG_DEBUG_PAGEALLOC to rather check for debug_pagealloc_enabled() and 
>> agree that it is only enabled for debug_pagealloc=on, then this would seem 
>> fine.  However, I think we should at least consult with those users before 
>> removing an artifact from the kernel log that could be useful in debugging 
>> why a particular BUG() happened.
> 
> Yes, at least, non-architecture dependent code (vmalloc, SLAB, SLUB) should
> be changed first. If Christian doesn't mind, I will try to fix above 3
> things.

Ok. So I will change this as Heiko and Thomas suggested for s390 and x86 and 
resend these 3 patches. Feel free to work on the other areas.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
