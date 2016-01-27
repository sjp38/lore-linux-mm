Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 70E336B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 07:42:00 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l65so143389806wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:42:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xu3si8309697wjc.5.2016.01.27.04.41.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 04:41:59 -0800 (PST)
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
 <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com>
 <20160126181903.GB4671@osiris>
 <alpine.DEB.2.10.1601261525580.25141@chino.kir.corp.google.com>
 <20160127001918.GA7089@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1601261633520.6121@chino.kir.corp.google.com>
 <20160127005920.GB7089@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A8BB15.9070305@suse.cz>
Date: Wed, 27 Jan 2016 13:41:57 +0100
MIME-Version: 1.0
In-Reply-To: <20160127005920.GB7089@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On 01/27/2016 01:59 AM, Joonsoo Kim wrote:
> On Tue, Jan 26, 2016 at 04:36:11PM -0800, David Rientjes wrote:
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

I think it might be worth also to convert debug_pagealloc_enabled() to be based
on static key, like I did for page_owner [1]. That should help make it possible
to have virtually no overhead when compiling kernel with CONFIG_DEBUG_PAGEALLOC
without enabling it boot-time. I assume it's one of the goals here?

[1] http://www.spinics.net/lists/linux-mm/msg100795.html

> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
