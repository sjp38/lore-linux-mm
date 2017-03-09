Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85A052808C6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 07:55:36 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 126so88230391oig.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 04:55:36 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0100.outbound.protection.outlook.com. [104.47.2.100])
        by mx.google.com with ESMTPS id e62si2929992otb.307.2017.03.09.04.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 04:55:35 -0800 (PST)
Subject: Re: [PATCH v2 6/9] kasan: improve slab object description
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-7-andreyknvl@google.com>
 <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
 <CAG_fn=Vn1tWsRbt4ohkE0E2ijAZsBvVuPS-Ond2KHVh9WK1zkg@mail.gmail.com>
 <2bbe7bdc-8842-8ec0-4b5a-6a8dce39216d@virtuozzo.com>
 <CAAeHK+xnHx5fvhq158+oxMxieG7a+gG7i0MQS92DqxYGe0O=Ww@mail.gmail.com>
 <576aeb81-9408-13fa-041d-a6bd1e2cf895@virtuozzo.com>
 <CAAeHK+w087z_pEWN=ZBDZN=XqqQMFZ9eevX44LERFV-d=G3F8g@mail.gmail.com>
 <CAAeHK+xCo+JcFstGz+xhgX2qvkP1zpwOg9VD0N-oD4Q=YcSi7A@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <69679f30-e502-d2cf-8dee-4ee88f64f887@virtuozzo.com>
Date: Thu, 9 Mar 2017 15:56:43 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+xCo+JcFstGz+xhgX2qvkP1zpwOg9VD0N-oD4Q=YcSi7A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/06/2017 08:16 PM, Andrey Konovalov wrote:

>>
>> What about
>>
>> Object at ffff880068388540 belongs to cache kmalloc-128 of size 128
>> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
>>
>> ?
> 
> Another alternative:
> 
> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
> Object belongs to cache kmalloc-128 of size 128
> 

Is it something wrong with just printing offset at the end as I suggested earlier?
It's more compact and also more clear IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
