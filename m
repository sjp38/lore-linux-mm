Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C87E36B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:22:39 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n69so365671327ion.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:22:39 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0133.outbound.protection.outlook.com. [104.47.2.133])
        by mx.google.com with ESMTPS id i11si881553oih.211.2016.08.02.03.22.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 03:22:39 -0700 (PDT)
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory
 systems
References: <1470063563-96266-1-git-send-email-glider@google.com>
 <57A06F23.9080804@virtuozzo.com>
 <CACT4Y+ad6ZY=1=kM0FGZD8LtOaupV4c0AW0mXjMoxMNRsH2omA@mail.gmail.com>
 <CAG_fn=X2zahG9enAdSPxwqC-VV6nwK2PhuAXPyhOvASnXok9JQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57A074AF.3040505@virtuozzo.com>
Date: Tue, 2 Aug 2016 13:23:43 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=X2zahG9enAdSPxwqC-VV6nwK2PhuAXPyhOvASnXok9JQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 08/02/2016 01:07 PM, Alexander Potapenko wrote:
> On Tue, Aug 2, 2016 at 12:05 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Tue, Aug 2, 2016 at 12:00 PM, Andrey Ryabinin
>>>
>>> Why WARN? I'd suggest pr_warn_once();
>>
>>
>> I would suggest to just do something useful. Setting quarantine
>> new_quarantine_size to 0 looks fine.
>> What would user do with this warning? Number of CPUs and amount of
>> memory are generally fixed. Why is it an issue for end user at all? We
>> still have some quarantine per-cpu. A WARNING means a [non-critical]
>> kernel bug. E.g. syzkaller will catch each and every boot of such
>> system as a bug.
> How about printk_once then?
> Silently setting the quarantine size to zero may puzzle the user.
>

Nope, user will not notice anything. So keeping it silent would be better.
Plus it's very unlikely that this will ever happen in real life.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
