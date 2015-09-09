Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 415ED6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 09:28:59 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so99334187igb.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 06:28:59 -0700 (PDT)
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com. [209.85.223.180])
        by mx.google.com with ESMTPS id a18si2226682igr.7.2015.09.09.06.28.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 06:28:58 -0700 (PDT)
Received: by ioii196 with SMTP id i196so21685990ioi.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 06:28:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150909132710.GG4973@codeblueprint.co.uk>
References: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440609089-14787-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<20150909132710.GG4973@codeblueprint.co.uk>
Date: Wed, 9 Sep 2015 15:28:57 +0200
Message-ID: <CAKv+Gu_haQp2+7Tpz74ZRbHBOQ+dYs9+orwNrMajmp3uyhNd3g@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] efi: Change abbreviation of EFI_MEMORY_RUNTIME
 from "RUN" to "RT"
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Jones <pjones@redhat.com>, Laszlo Ersek <lersek@redhat.com>, Borislav Petkov <bp@alien8.de>

On 9 September 2015 at 15:27, Matt Fleming <matt@codeblueprint.co.uk> wrote:
> On Thu, 27 Aug, at 02:11:29AM, Taku Izumi wrote:
>> Now efi_md_typeattr_format() outputs "RUN" if passed EFI memory
>> descriptor has EFI_MEMORY_RUNTIME attribute. But "RT" is preferer
>> because it is shorter and clearer.
>>
>> This patch changes abbreviation of EFI_MEMORY_RUNTIME from "RUN"
>> to "RT".
>>
>> Suggested-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
>> ---
>>  drivers/firmware/efi/efi.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
>> index 8124078..25b6477 100644
>> --- a/drivers/firmware/efi/efi.c
>> +++ b/drivers/firmware/efi/efi.c
>> @@ -594,8 +594,8 @@ char * __init efi_md_typeattr_format(char *buf, size_t size,
>>               snprintf(pos, size, "|attr=0x%016llx]",
>>                        (unsigned long long)attr);
>>       else
>> -             snprintf(pos, size, "|%3s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
>> -                      attr & EFI_MEMORY_RUNTIME ? "RUN" : "",
>> +             snprintf(pos, size, "|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
>> +                      attr & EFI_MEMORY_RUNTIME ? "RT" : "",
>>                        attr & EFI_MEMORY_MORE_RELIABLE ? "MR" : "",
>>                        attr & EFI_MEMORY_XP      ? "XP"  : "",
>>                        attr & EFI_MEMORY_RP      ? "RP"  : "",
>
> I know that Ard suggested this change but I don't think I should apply
> this and the reason is that developers, particularly distro
> developers, come to rely on the output we print for debugging
> purposes.
>
> They don't necessarily monitor all the patches getting merged upstream
> closely enough to realise that it impacts their debugging strategy. So
> when they notice that the output has gone from "RUN" to "RT" they're
> naturally going to ask what the difference is... and the answer is "it
> looks prettier". That's not a good enough reason.
>
> Obviously if we're printing something that's completely incorrect, or
> we can improve the message considerably, then yes, it makes sense to
> change it - but that's not the case here.
>
> Thanks for the patch, but sorry, I'm not going to apply this one.
>

Ack. It was more an illustration of my argument for preferring MR over
REL[IY] than anything else,.

-- 
ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
