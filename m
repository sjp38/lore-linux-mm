Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAC5B6B04AF
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:52:12 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i1so2122500oib.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:52:12 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id d14si1032725oih.97.2017.08.28.14.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:52:12 -0700 (PDT)
Received: by mail-io0-x231.google.com with SMTP id 81so8332122ioj.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:52:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1503956551.2841.70.camel@wdc.com>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-18-git-send-email-keescook@chromium.org> <1503956551.2841.70.camel@wdc.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 28 Aug 2017 14:52:10 -0700
Message-ID: <CAGXu5jKuuJ9o0rJWExknajKBNTsnfmsJAmhK4jq5v+VTRZo9gQ@mail.gmail.com>
Subject: Re: [PATCH v2 17/30] scsi: Define usercopy region in scsi_sense_cache
 slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "dave@nullcore.net" <dave@nullcore.net>

On Mon, Aug 28, 2017 at 2:42 PM, Bart Van Assche <Bart.VanAssche@wdc.com> wrote:
> On Mon, 2017-08-28 at 14:34 -0700, Kees Cook wrote:
>> diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
>> index f6097b89d5d3..f1c6bd56dd5b 100644
>> --- a/drivers/scsi/scsi_lib.c
>> +++ b/drivers/scsi/scsi_lib.c
>> @@ -77,14 +77,15 @@ int scsi_init_sense_cache(struct Scsi_Host *shost)
>>       if (shost->unchecked_isa_dma) {
>>               scsi_sense_isadma_cache =
>>                       kmem_cache_create("scsi_sense_cache(DMA)",
>> -                     SCSI_SENSE_BUFFERSIZE, 0,
>> -                     SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA, NULL);
>> +                             SCSI_SENSE_BUFFERSIZE, 0,
>> +                             SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA, NULL);
>>               if (!scsi_sense_isadma_cache)
>>                       ret = -ENOMEM;
>
> All this part of this patch does is to change source code indentation. Should
> these changes really be included in this patch?

I can certainly drop that hunk, but the existing alignment is really
ugly. :) Happy to do whatever.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
