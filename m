Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id 161B56B004D
	for <linux-mm@kvack.org>; Mon, 12 May 2014 21:45:09 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id jz11so9878668veb.35
        for <linux-mm@kvack.org>; Mon, 12 May 2014 18:45:08 -0700 (PDT)
Received: from mail-vc0-x242.google.com (mail-vc0-x242.google.com [2607:f8b0:400c:c03::242])
        by mx.google.com with ESMTPS id uv3si2375839vdc.95.2014.05.12.18.45.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 18:45:08 -0700 (PDT)
Received: by mail-vc0-f194.google.com with SMTP id hr9so1767621vcb.9
        for <linux-mm@kvack.org>; Mon, 12 May 2014 18:45:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5146762.jba3IJe7xt@wuerfel>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
	<1399861195-21087-3-git-send-email-superlibj8301@gmail.com>
	<5146762.jba3IJe7xt@wuerfel>
Date: Tue, 13 May 2014 09:45:08 +0800
Message-ID: <CAHPCO9FRfR5p1N5v7mUk4hUYdPvqfLN6nW1LcnC83sU86ZFbZA@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/2] ARM: ioremap: Add IO mapping space reused support.
From: Richard Lee <superlibj8301@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj@gmail.com>

> On Mon, May 12, 2014 at 3:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday 12 May 2014 10:19:55 Richard Lee wrote:
>> For the IO mapping, for the same physical address space maybe
>> mapped more than one time, for example, in some SoCs:
>> 0x20000000 ~ 0x20001000: are global control IO physical map,
>> and this range space will be used by many drivers.
>> And then if each driver will do the same ioremap operation, we
>> will waste to much malloc virtual spaces.
>>
>> This patch add IO mapping space reused support.
>>
>> Signed-off-by: Richard Lee <superlibj@gmail.com>
>
> What happens if the first driver then unmaps the area?
>

If the first driver will unmap the area, it shouldn't do any thing
except decreasing the 'used' counter.

Thanks,

BRs
Richard Lee


>         Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
