Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id EA8506B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:09:20 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l66so1736557wml.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:09:20 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id w77si11017477wme.5.2016.01.27.05.09.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 05:09:20 -0800 (PST)
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 27 Jan 2016 13:09:19 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0C6D01B08067
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:09:18 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0RD9Arf10748214
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:09:10 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0RD99SP014362
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:09:09 -0700
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
 <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com>
 <20160126181903.GB4671@osiris>
 <alpine.DEB.2.10.1601261525580.25141@chino.kir.corp.google.com>
 <20160127001918.GA7089@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1601261633520.6121@chino.kir.corp.google.com>
 <20160127005920.GB7089@js1304-P5Q-DELUXE> <56A8BB15.9070305@suse.cz>
 <56A8BC6D.9080101@de.ibm.com> <56A8C028.7050305@suse.cz>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56A8C175.9030702@de.ibm.com>
Date: Wed, 27 Jan 2016 14:09:09 +0100
MIME-Version: 1.0
In-Reply-To: <56A8C028.7050305@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On 01/27/2016 02:03 PM, Vlastimil Babka wrote:
> On 01/27/2016 01:47 PM, Christian Borntraeger wrote:
>> On 01/27/2016 01:41 PM, Vlastimil Babka wrote:
>>> On 01/27/2016 01:59 AM, Joonsoo Kim wrote:
>>>
>>> I think it might be worth also to convert debug_pagealloc_enabled() to be based
>>> on static key, like I did for page_owner [1]. That should help make it possible
>>> to have virtually no overhead when compiling kernel with CONFIG_DEBUG_PAGEALLOC
>>> without enabling it boot-time. I assume it's one of the goals here?
>>
>> We could do something like that but dump_stack and setup of the initial identity
>> mapping of the kernel as well as the initial page protection are not hot path
>> as far as I can tell. Any other places?
> 
> Well, mostly kernel_map_pages() which is used in page allocation hotpaths.

Right. So indeed, static_key would be a good thing, but certainly an addon patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
