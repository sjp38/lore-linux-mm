Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90B156B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:40:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g32so13796845wrd.8
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:40:07 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.12])
        by mx.google.com with ESMTPS id k16si5407595wrc.148.2017.08.14.04.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 04:40:06 -0700 (PDT)
Subject: Re: [PATCH 1/2] kmemleak: Delete an error message for a failed memory
 allocation in two functions
References: <301bc8c9-d9f6-87be-ce1d-dc614e82b45b@users.sourceforge.net>
 <986426ab-4ca9-ee56-9712-d06c25a2ed1a@users.sourceforge.net>
 <20170814111430.lskrrg3fygpnyx6v@armageddon.cambridge.arm.com>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <8e1d5cce-3661-44cc-ea1c-ac754513cde4@users.sourceforge.net>
Date: Mon, 14 Aug 2017 13:40:04 +0200
MIME-Version: 1.0
In-Reply-To: <20170814111430.lskrrg3fygpnyx6v@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

>> +++ b/mm/kmemleak.c
>> @@ -555,7 +555,6 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>>  
>>  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
>>  	if (!object) {
>> -		pr_warn("Cannot allocate a kmemleak_object structure\n");
>>  		kmemleak_disable();
> 
> I don't really get what this patch is trying to achieve.

I suggest to reduce the code size a bit.


> Given that kmemleak will be disabled after this,

I have got difficulties to interpret this information.


> I'd rather know why it happened.

Do you find the default allocation failure report sufficient?

Regards,
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
