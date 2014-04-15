Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 92FA66B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 19:58:16 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so10166722pab.41
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 16:58:16 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id z10si11656931pbx.181.2014.04.15.16.58.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Apr 2014 16:58:15 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: Re: [PATCH v2] mm: convert some level-less printks to pr_*
References: <1395942859-11611-1-git-send-email-mitchelh@codeaurora.org>
	<1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
	<20140414155526.96b0832bf4660c026bc3a1d9@linux-foundation.org>
Date: Tue, 15 Apr 2014 16:58:21 -0700
In-Reply-To: <20140414155526.96b0832bf4660c026bc3a1d9@linux-foundation.org>
	(Andrew Morton's message of "Mon, 14 Apr 2014 15:55:26 -0700")
Message-ID: <vnkwvbuaywki.fsf@mitchelh-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 14 2014 at 03:55:26 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 27 Mar 2014 10:54:19 -0700 Mitchel Humpherys <mitchelh@codeaurora.org> wrote:
>>  #include <linux/mm.h>
>>  #include <linux/export.h>
>>  #include <linux/swap.h>
>> @@ -15,6 +17,7 @@
>>  #include <linux/hash.h>
>>  #include <linux/highmem.h>
>>  #include <linux/bootmem.h>
>> +#include <linux/printk.h>
>>  #include <asm/tlbflush.h>
>>  
>>  #include <trace/events/block.h>
>> @@ -34,7 +37,7 @@ static __init int init_emergency_pool(void)
>>  
>>  	page_pool = mempool_create_page_pool(POOL_SIZE, 0);
>>  	BUG_ON(!page_pool);
>> -	printk("bounce pool size: %d pages\n", POOL_SIZE);
>> +	pr_info("bounce pool size: %d pages\n", POOL_SIZE);
>
> This used to print "bounce pool size: N pages" but will now print
> "bounce: bounce pool size: N pages".
>
> It isn't necessarily a *bad* change but perhaps a little more thought
> could be put into it.  In this example it would be better remove the
> redundancy by using 
>
> 	pr_info("pool size: %d pages\n"...);

Yes I noticed this in my boot-test... I'll change it to remove the
redundancy. The others all seem okay.

>
> And all of this should be described and justified in the changelog,
> please.

Will send a v3 shortly. Thanks for your comments.

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
