Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADE116B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:17:35 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q12so9169932plk.16
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:17:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 88sor3168998pla.70.2017.12.20.01.17.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 01:17:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219155323.7ed0dcfbc89c76eb87aca592@linux-foundation.org>
References: <CACT4Y+a0NvG-qpufVcvObd_hWKF9xmTjmjCvV3_13LSgcFXL+Q@mail.gmail.com>
 <20171219090319.GD2787@dhcp22.suse.cz> <7cec6594-94c7-a238-4046-0061a9adc20d@infradead.org>
 <20171219155323.7ed0dcfbc89c76eb87aca592@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Dec 2017 10:17:13 +0100
Message-ID: <CACT4Y+ba1EiGmWkDQbrnGG64qds0KzQhgij2qch6uV2zcjcC_w@mail.gmail.com>
Subject: Re: mmots build error: version control conflict marker in file
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Dec 20, 2017 at 12:53 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 19 Dec 2017 12:00:12 -0800 Randy Dunlap <rdunlap@infradead.org> wrote:
>
>>
>> Wow. arch/x86/include/asm/processor.h around line 340++ looks like this:
>>
>> <<<<<<< HEAD
>> struct SYSENTER_stack {
>>       unsigned long           words[64];
>> };
>>
>> struct SYSENTER_stack_page {
>>       struct SYSENTER_stack stack;
>> =======
>> struct entry_stack {
>>       unsigned long           words[64];
>> };
>>
>> struct entry_stack_page {
>>       struct entry_stack stack;
>> >>>>>>> linux-next/akpm-base
>> } __aligned(PAGE_SIZE);
>
> Yeah, sorry.  Normally I fix those my hand in
> linux-next-git-rejects.patch but there were sooooooo many yesterday
> that I said screwit.  That all got resolved in today's pull.

Thanks. I see that syzbot was able to successfully build mmots today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
