Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7E01B6B007E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 09:09:18 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id td3so54820948pab.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 06:09:18 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id y26si25742pfa.187.2016.04.07.06.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 06:09:17 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id 184so55815113pff.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 06:09:17 -0700 (PDT)
Date: Thu, 7 Apr 2016 23:07:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on
 big endian
Message-ID: <20160407140702.GB464@swordfish>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
 <20160405153439.GA2647@kroah.com>
 <CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
 <20160406053325.GA415@swordfish>
 <CALjTZvZaD7VHieU4A_5JAGZfN-7toWGm1UpM3zqreP6YsvA37A@mail.gmail.com>
 <20160406130911.GA584@swordfish>
 <CALjTZva=ocKHU8hdwmrQZvK-5QnHcc4EQD7CogJuELYk7=J=Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALjTZva=ocKHU8hdwmrQZvK-5QnHcc4EQD7CogJuELYk7=J=Og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org, Chanho Min <chanho.min@lge.com>, Kyungsik Lee <kyungsik.lee@lge.com>

On (04/07/16 13:33), Rui Salvaterra wrote:
[..]
> Hi again, Sergey

Hello,

> Thanks for the patch, I'll test it as soon as possible. I agree with
> your second option, usually one selects lz4 when (especially
> decompression) speed is paramount, so it needs all the help it can
> get.

thanks!

> Speaking of fishy, the 64-bit detection code also looks suspiciously
> bogus. Some of the identifiers don't even exist anywhere in the kernel
> (__ppc64__, por example, after grepping all .c and .h files).
> Shouldn't we instead check for CONFIG_64BIT or BITS_PER_LONG == 64?

definitely a good question. personally, I'd prefer to test for
CONFIG_64BIT only, looking at this hairy

  /* Detects 64 bits mode */
  #if (defined(__x86_64__) || defined(__x86_64) || defined(__amd64__) \
         || defined(__ppc64__) || defined(__LP64__))

and remove/rewrite a bunch of other stuff. but the thing with cleanups
is that they don't fix anything, while potentially can introduce bugs.
it's more risky to touch the stable code. /* well, removing those 'ghost'
identifiers is sort of OK to me */. but that's just my opinion, I'll
leave it to you and Greg.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
