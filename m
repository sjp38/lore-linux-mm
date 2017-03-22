Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB336B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 12:53:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g2so385316938pge.7
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 09:53:02 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40109.outbound.protection.outlook.com. [40.107.4.109])
        by mx.google.com with ESMTPS id 31si2441680pli.135.2017.03.22.09.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 09:53:01 -0700 (PDT)
Subject: Re: [PATCH] kasan: report only the first error
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
 <CAAeHK+zt9U+_8o4-k1mTvHsNTVGnKbzy7jVz2jn=TkNFf2neHQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <cbb22acb-1228-0f7b-c7a0-5822ea721b3f@virtuozzo.com>
Date: Wed, 22 Mar 2017 19:54:17 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+zt9U+_8o4-k1mTvHsNTVGnKbzy7jVz2jn=TkNFf2neHQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/22/2017 07:34 PM, Andrey Konovalov wrote:
> On Wed, Mar 22, 2017 at 5:06 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> Disable kasan after the first report. There are several reasons for this:
>>  * Single bug quite often has multiple invalid memory accesses causing
>>     storm in the dmesg.
>>  * Write OOB access might corrupt metadata so the next report will print
>>     bogus alloc/free stacktraces.
>>  * Reports after the first easily could be not bugs by itself but just side
>>     effects of the first one.
>>
>> Given that multiple reports only do harm, it makes sense to disable
>> kasan after the first one. Except for the tests in lib/test_kasan.c
>> as we obviously want to see all reports from test.
> 
> Hi Andrey,
> 
> Could you make it configurable via CONFIG_KASAN_SOMETHING (which can
> default to showing only the first report)?

I'd rather make this boot time configurable, but wouldn't want to without
a good reason.


> I sometimes use KASAN to see what bad accesses a particular bug
> causes, and seeing all of them (even knowing that they may be
> corrupt/induced) helps a lot.

I'm wondering why you need to see all reports?

> 
> Thanks!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
