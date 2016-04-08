Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC066B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 10:53:32 -0400 (EDT)
Received: by mail-lf0-f52.google.com with SMTP id c126so80967789lfb.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 07:53:32 -0700 (PDT)
Received: from mail-lb0-x243.google.com (mail-lb0-x243.google.com. [2a00:1450:4010:c04::243])
        by mx.google.com with ESMTPS id o2si7130487lfa.61.2016.04.08.07.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 07:53:31 -0700 (PDT)
Received: by mail-lb0-x243.google.com with SMTP id q4so8861859lbq.3
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 07:53:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160407140702.GB464@swordfish>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
	<20160405153439.GA2647@kroah.com>
	<CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
	<20160406053325.GA415@swordfish>
	<CALjTZvZaD7VHieU4A_5JAGZfN-7toWGm1UpM3zqreP6YsvA37A@mail.gmail.com>
	<20160406130911.GA584@swordfish>
	<CALjTZva=ocKHU8hdwmrQZvK-5QnHcc4EQD7CogJuELYk7=J=Og@mail.gmail.com>
	<20160407140702.GB464@swordfish>
Date: Fri, 8 Apr 2016 15:53:30 +0100
Message-ID: <CALjTZvYx+zYV0SHWR0=C+jhQ0M9BbeU0TRRuPDks_B4ZkZpVaA@mail.gmail.com>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on big endian
From: Rui Salvaterra <rsalvaterra@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org, Chanho Min <chanho.min@lge.com>, Kyungsik Lee <kyungsik.lee@lge.com>

2016-04-07 15:07 GMT+01:00 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>:
> On (04/07/16 13:33), Rui Salvaterra wrote:
> [..]
>> Hi again, Sergey
>
> Hello,
>
>> Thanks for the patch, I'll test it as soon as possible. I agree with
>> your second option, usually one selects lz4 when (especially
>> decompression) speed is paramount, so it needs all the help it can
>> get.
>
> thanks!
>
>> Speaking of fishy, the 64-bit detection code also looks suspiciously
>> bogus. Some of the identifiers don't even exist anywhere in the kernel
>> (__ppc64__, por example, after grepping all .c and .h files).
>> Shouldn't we instead check for CONFIG_64BIT or BITS_PER_LONG == 64?
>
> definitely a good question. personally, I'd prefer to test for
> CONFIG_64BIT only, looking at this hairy
>
>   /* Detects 64 bits mode */
>   #if (defined(__x86_64__) || defined(__x86_64) || defined(__amd64__) \
>          || defined(__ppc64__) || defined(__LP64__))
>
> and remove/rewrite a bunch of other stuff. but the thing with cleanups
> is that they don't fix anything, while potentially can introduce bugs.
> it's more risky to touch the stable code. /* well, removing those 'ghost'
> identifiers is sort of OK to me */. but that's just my opinion, I'll
> leave it to you and Greg.
>
>         -ss

Hi again, Sergey

I finally was able to test your patch but, as I suspected, it wasn't
enough. However, based on it, I was able to write a (hopefully)
correct one, which I'll send soon (tested on ppc64, with no
regressions on x86_64).

Thanks,

Rui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
