Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5C56B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 16:53:46 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id r129so138421778wmr.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:53:46 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id b188si7658139wme.79.2016.02.02.13.53.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 13:53:42 -0800 (PST)
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 2 Feb 2016 21:53:41 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id DE65A17D8059
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 21:53:49 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u12Lrcdf7668094
	for <linux-mm@kvack.org>; Tue, 2 Feb 2016 21:53:38 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u12Lrb4p020575
	for <linux-mm@kvack.org>; Tue, 2 Feb 2016 16:53:38 -0500
Subject: Re: [PATCH v3 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
 <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
 <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com>
 <56A9E3D1.3090001@de.ibm.com>
 <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1602021351290.4977@chino.kir.corp.google.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56B12560.4010201@de.ibm.com>
Date: Tue, 2 Feb 2016 22:53:36 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1602021351290.4977@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On 02/02/2016 10:51 PM, David Rientjes wrote:
> On Thu, 28 Jan 2016, David Rientjes wrote:
> 
>> On Thu, 28 Jan 2016, Christian Borntraeger wrote:
>>
>>> Indeed, I only touched the identity mapping and dump stack.
>>> The question is do we really want to change free_init_pages as well?
>>> The unmapping during runtime causes significant overhead, but the
>>> unmapping after init imposes almost no runtime overhead. Of course,
>>> things get fishy now as what is enabled and what not.
>>>
>>> Kconfig after my patch "mm/debug_pagealloc: Ask users for default setting of debug_pagealloc"
>>> (in mm) now states
>>> ----snip----
>>> By default this option will have a small overhead, e.g. by not
>>> allowing the kernel mapping to be backed by large pages on some
>>> architectures. Even bigger overhead comes when the debugging is
>>> enabled by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc
>>> command line parameter.
>>> ----snip----
>>>
>>> So I am tempted to NOT change free_init_pages, but the x86 maintainers
>>> can certainly decide differently. Ingo, Thomas, H. Peter, please advise.
>>>
>>
>> I'm sorry, but I thought the discussion of the previous version of the 
>> patchset led to deciding that all CONFIG_DEBUG_PAGEALLOC behavior would be 
>> controlled by being enabled on the commandline and checked with 
>> debug_pagealloc_enabled().
>>
>> I don't think we should have a CONFIG_DEBUG_PAGEALLOC that does some stuff 
>> and then a commandline parameter or CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT 
>> to enable more stuff.  It should either be all enabled by the commandline 
>> (or config option) or split into a separate entity.  
>> CONFIG_DEBUG_PAGEALLOC_LIGHT and CONFIG_DEBUG_PAGEALLOC would be fine, but 
>> the current state is very confusing about what is being done and what 
>> isn't.
>>
> 
> Ping?
> 
https://lkml.org/lkml/2016/1/29/266 
?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
