Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 073856B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 13:43:57 -0400 (EDT)
Received: by mail-oi0-f44.google.com with SMTP id x69so11162027oia.3
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 10:43:57 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id 4si10980704oiu.36.2014.10.12.10.43.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 12 Oct 2014 10:43:57 -0700 (PDT)
Received: by mail-oi0-f48.google.com with SMTP id g201so11179264oib.21
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 10:43:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141012.133047.427141450441745027.davem@davemloft.net>
References: <20141011.221510.1574777235900788349.davem@davemloft.net>
	<CAAmzW4Nrzp8TKurmevqmAV5kVRP2af1wZKqYcYH9RXroTZavpw@mail.gmail.com>
	<20141012.133047.427141450441745027.davem@davemloft.net>
Date: Mon, 13 Oct 2014 02:43:57 +0900
Message-ID: <CAAmzW4Pc=i9zHh5133Zc1rDRM1vaot18xXYwoMk8tTGtttwFgw@mail.gmail.com>
Subject: Re: unaligned accesses in SLAB etc.
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

2014-10-13 2:30 GMT+09:00 David Miller <davem@davemloft.net>:
> From: Joonsoo Kim <js1304@gmail.com>
> Date: Mon, 13 Oct 2014 02:22:15 +0900
>
>> Could you test below patch?
>> If it fixes your problem, I will send it with proper description.
>
> It works, I just tested using ARCH_KMALLOC_MINALIGN which would be
> better.

Oops. resend with whole Cc list.

Thanks for testing.
ARCH_KMALLOC_MINALIGN is for object alignment,
but, current problem is caused by alignment of cpu cache array.
I think that my fix is more proper in this situation.
I will send fix tomorrow,
because I'd like to test more and it's 2:42 am. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
