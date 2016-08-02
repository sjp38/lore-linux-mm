Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F135C828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:33:00 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i64so99565511ith.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:33:00 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0125.outbound.protection.outlook.com. [104.47.1.125])
        by mx.google.com with ESMTPS id 32si1376517otf.203.2016.08.02.05.32.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 05:33:00 -0700 (PDT)
Subject: Re: [PATCH 6/6] kasan: improve double-free reports.
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
 <1470062715-14077-6-git-send-email-aryabinin@virtuozzo.com>
 <CAG_fn=WP2VmNNuzp1YMi+vPLaG9B3JH9TD4FfzxVyeZL2AyM_Q@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57A0933F.8000706@virtuozzo.com>
Date: Tue, 2 Aug 2016 15:34:07 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=WP2VmNNuzp1YMi+vPLaG9B3JH9TD4FfzxVyeZL2AyM_Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>



On 08/02/2016 02:39 PM, Alexander Potapenko wrote:

>> +static void kasan_end_report(unsigned long *flags)
>> +{
>> +       pr_err("==================================================================\n");
>> +       add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
> Don't we want to add the taint as early as possible once we've
> detected the error?

What for?
It certainly shouldn't be before dump_stack(), otherwise on the first report the kernel will claimed as tainted.


>>
>> +void kasan_report_double_free(struct kmem_cache *cache, void *object,
>> +                       s8 shadow)
>> +{
>> +       unsigned long flags;
>> +
>> +       kasan_start_report(&flags);
>> +       pr_err("BUG: Double free or corrupt pointer\n");
> How about "Double free or freeing an invalid pointer\n"?
> I think "corrupt pointer" doesn't exactly reflect where the bug is.

Ok

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
