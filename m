Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id C9DE66B0264
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 12:02:23 -0400 (EDT)
Received: by mail-lf0-f41.google.com with SMTP id e190so12168559lfe.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 09:02:23 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id f68si5420874lff.179.2016.04.05.09.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 09:02:22 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id e190so12168200lfe.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 09:02:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160405153439.GA2647@kroah.com>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
	<20160405153439.GA2647@kroah.com>
Date: Tue, 5 Apr 2016 17:02:21 +0100
Message-ID: <CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on big endian
From: Rui Salvaterra <rsalvaterra@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org

2016-04-05 16:34 GMT+01:00 Greg KH <gregkh@linuxfoundation.org>:
> On Tue, Apr 05, 2016 at 03:07:48PM +0100, Rui Salvaterra wrote:
>> Hi,
>>
>>
>> I apologise in advance if I've cc'ed too many/the wrong people/lists.
>>
>> Whenever I try to use zram with lz4, on my Power Mac G5 (tested with
>> kernel 4.4.0-16-powerpc64-smp from Ubuntu 16.04 LTS), I get the
>> following on my dmesg:
>>
>> [13150.675820] zram: Added device: zram0
>> [13150.704133] zram0: detected capacity change from 0 to 5131976704
>> [13150.715960] zram: Decompression failed! err=-1, page=0
>> [13150.716008] zram: Decompression failed! err=-1, page=0
>> [13150.716027] zram: Decompression failed! err=-1, page=0
>> [13150.716032] Buffer I/O error on dev zram0, logical block 0, async page read
>>
>> I believe Eunbong Song wrote a patch [1] to fix this (or a very
>> identical) bug on MIPS, but it never got merged (maybe
>> incorrect/incomplete?). Is there any hope of seeing this bug fixed?
>>
>>
>> Thanks,
>>
>> Rui Salvaterra
>>
>>
>> [1] http://comments.gmane.org/gmane.linux.kernel/1752745
>
> For some reason it never got merged, sorry, I don't remember why.
>
> Have you tested this patch?  If so, can you resend it with your
> tested-by: line added to it?
>
> thanks,
>
> greg k-h

Hi, Greg


No, I haven't tested the patch at all. I want to do so, and fix if if
necessary, but I still need to learn how to (meaning, I need to watch
your "first kernel patch" presentation again). I'd love to get
involved in kernel development, and this seems to be a good
opportunity, if none of the kernel gods beat me to it (I may need a
month, but then again nobody complained about this bug in almost two
years).


Thanks,

Rui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
