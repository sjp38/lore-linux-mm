Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 81F3A6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:34:00 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so3489046pbb.6
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 11:34:00 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id qv10si7628723pbb.142.2014.01.30.11.33.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 11:33:59 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3387362pde.34
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 11:33:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52EAA714.3080809@infradead.org>
References: <CAOvWMLa334E8CYJLrHy6-0ZXBRneoMf-05v422SQw+dbGRubow@mail.gmail.com>
	<52EAA714.3080809@infradead.org>
Date: Thu, 30 Jan 2014 11:33:59 -0800
Message-ID: <CAOvWMLbs-sP+gJHV_5O6ZbV8eTpEKPVRVR238gFcPQeqhCjT3A@mail.gmail.com>
Subject: Re: [BUG] Description for memmap in kernel-parameters.txt is wrong
From: Andiry Xu <andiry@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, Andiry Xu <andiry.xu@gmail.com>, Linux MM <linux-mm@kvack.org>

On Thu, Jan 30, 2014 at 11:25 AM, Randy Dunlap <rdunlap@infradead.org> wrote:
> [adding linux-mm mailing list]
>
> On 01/30/2014 08:52 AM, Andiry Xu wrote:
>> Hi,
>>
>> In kernel-parameters.txt, there is following description:
>>
>> memmap=nn[KMG]$ss[KMG]
>>                         [KNL,ACPI] Mark specific memory as reserved.
>>                         Region of memory to be used, from ss to ss+nn.
>
> Should be:
>                           Region of memory to be reserved, from ss to ss+nn.
>
> but that doesn't help with the problem that you describe, does it?
>

Actually it should be:
                             Region of memory to be reserved, from nn to nn+ss.

That is, exchange nn and ss.

>
>> Unfortunately this is incorrect. The meaning of nn and ss is reversed.
>> For example:
>>
>> Command                  Expected                 Result
>> memmap 2G$6G        6G - 8G reserved      2G - 8G reserved
>> memmap 6G$2G        2G - 8G reserved      6G - 8G reserved
>
> Are you testing on x86?
> The code in arch/x86/kernel/e820.c always parses mem_size followed by start address.
> I don't (yet) see where it goes wrong...
>

Yes, it's a x86 machine.

>
>> Test kernel version 3.13, but I believe the issue has been there long ago.
>>
>> I'm not sure whether the description or implementation should be
>> fixed, but apparently they do not match.
>
> I prefer to change the documentation and leave the implementation as is.
>

That's fine. memmap itself works OK, it's just the description is
wrong and people like me get confused.

Thanks,
Andiry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
