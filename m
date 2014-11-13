Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id C4FFB6B00E0
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:54:50 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id m8so10520546obr.22
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:54:50 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id lj5si1124797oeb.65.2014.11.13.05.54.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:54:49 -0800 (PST)
Received: by mail-ob0-f170.google.com with SMTP id nt9so11806510obb.15
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:54:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <000001cffee1$28362ed0$78a28c70$%yang@samsung.com>
References: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
	<20141113000216.GA1074@bbox>
	<000001cffee1$28362ed0$78a28c70$%yang@samsung.com>
Date: Thu, 13 Nov 2014 21:54:49 +0800
Message-ID: <CADAEsF87zYnN=6=HxvEhrfm8ridND-kvHAvh6sM_6vB9qHMDww@mail.gmail.com>
Subject: Re: [PATCH] mm/zram: correct ZRAM_ZERO flag bit position
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2014-11-13 9:27 GMT+08:00 Weijie Yang <weijie.yang@samsung.com>:
> On Thu, Nov 13, 2014 at 8:02 AM, Minchan Kim <minchan@kernel.org> wrote:
>> On Wed, Nov 12, 2014 at 10:37:18PM +0800, Mahendran Ganesh wrote:
>>> In struct zram_table_entry, the element *value* contains obj size and
>>> obj zram flags. Bit 0 to bit (ZRAM_FLAG_SHIFT - 1) represent obj size,
>>> and bit ZRAM_FLAG_SHIFT to the highest bit of unsigned long represent obj
>>> zram_flags. So the first zram flag(ZRAM_ZERO) should be from ZRAM_FLAG_SHIFT
>>> instead of (ZRAM_FLAG_SHIFT + 1).
>>>
>>> This patch fixes this issue.
>>>
>>> Also this patch fixes a typo, "page in now accessed" -> "page is now accessed"
>>>
>>> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
>> Acked-by: Minchan Kim <minchan@kernel.org>
>
> Acked-by: Weijie Yang <weijie.yang@samsung.com>

Thanks

>
>> To be clear about "fixes this issue", it's not a bug but just clean up
>> so it doesn't change any behavior.
>>
>> Thanks!
>>
>> --
>> Kind regards,
>> Minchan Kim
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
