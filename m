Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 372046B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:24:48 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id pv20so3837470lab.9
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 10:24:46 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g7si5992777lab.82.2014.04.11.10.24.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Apr 2014 10:24:45 -0700 (PDT)
Message-ID: <53482555.4070603@parallels.com>
Date: Fri, 11 Apr 2014 21:24:37 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] slab: document kmalloc_order
References: <20140410163831.c76596b0f8d0bef39a42c63f@linux-foundation.org> <1397220736-13840-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.10.1404111057390.13278@nuc>
In-Reply-To: <alpine.DEB.2.10.1404111057390.13278@nuc>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, gthelen@google.com, hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 04/11/2014 07:57 PM, Christoph Lameter wrote:
> On Fri, 11 Apr 2014, Vladimir Davydov wrote:
>
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index cab4c49b3e8c..3ffd2e76b5d2 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -573,6 +573,11 @@ void __init create_kmalloc_caches(unsigned long flags)
>>  }
>>  #endif /* !CONFIG_SLOB */
>>
>> +/*
>> + * To avoid unnecessary overhead, we pass through large allocation requests
>> + * directly to the page allocator. We use __GFP_COMP, because we will need to
>> + * know the allocation order to free the pages properly in kfree.
>> + */
>>  void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
>>  {
>>  	void *ret;
>>
> ??? kmalloc_order is defined in include/linux/slab.h

I moved it to slab_common.c in "[PATCH -mm v2.2] mm: get rid of
__GFP_KMEMCG"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
