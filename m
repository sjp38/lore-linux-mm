Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE1F6B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 22:13:23 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id sa20so1543844veb.41
        for <linux-mm@kvack.org>; Tue, 13 May 2014 19:13:23 -0700 (PDT)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id tv3si69409vdc.18.2014.05.13.19.13.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 19:13:22 -0700 (PDT)
Received: by mail-vc0-f176.google.com with SMTP id lg15so1601405vcb.35
        for <linux-mm@kvack.org>; Tue, 13 May 2014 19:13:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5026482.P9PDy29y2Y@wuerfel>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
	<5146762.jba3IJe7xt@wuerfel>
	<CAHPCO9FRfR5p1N5v7mUk4hUYdPvqfLN6nW1LcnC83sU86ZFbZA@mail.gmail.com>
	<5026482.P9PDy29y2Y@wuerfel>
Date: Wed, 14 May 2014 10:13:22 +0800
Message-ID: <CAHPCO9GkEHpyr=_nMxKPzPZZ6FaT3-h3n1eZ_-iRbXNiyEea4Q@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/2] ARM: ioremap: Add IO mapping space reused support.
From: Richard Lee <superlibj8301@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj@gmail.com>

On Tue, May 13, 2014 at 4:43 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday 13 May 2014 09:45:08 Richard Lee wrote:
>> > On Mon, May 12, 2014 at 3:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> > On Monday 12 May 2014 10:19:55 Richard Lee wrote:
>> >> For the IO mapping, for the same physical address space maybe
>> >> mapped more than one time, for example, in some SoCs:
>> >> 0x20000000 ~ 0x20001000: are global control IO physical map,
>> >> and this range space will be used by many drivers.
>> >> And then if each driver will do the same ioremap operation, we
>> >> will waste to much malloc virtual spaces.
>> >>
>> >> This patch add IO mapping space reused support.
>> >>
>> >> Signed-off-by: Richard Lee <superlibj@gmail.com>
>> >
>> > What happens if the first driver then unmaps the area?
>> >
>>
>> If the first driver will unmap the area, it shouldn't do any thing
>> except decreasing the 'used' counter.
>
> Ah, for some reason I didn't see your first patch that introduces
> that counter.
>

It's "[PATCH 1/2] mm/vmalloc: Add IO mapping space reused".

Thanks,

BRs
Richard



>         Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
