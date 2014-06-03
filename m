Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id B9C196B0036
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 11:19:58 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id to1so6145111ieb.30
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 08:19:58 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id q9si1369787icv.107.2014.06.03.08.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 08:19:57 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so6080745iec.40
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 08:19:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140603141138.GH16741@pengutronix.de>
References: <20140429100028.GH28564@pengutronix.de>
	<20140602085150.GA31147@pengutronix.de>
	<538DBC3F.9060207@uclinux.org>
	<20140603141138.GH16741@pengutronix.de>
Date: Tue, 3 Jun 2014 17:19:56 +0200
Message-ID: <CAMuHMdXpOcWhsjMRaW6YVeK4g-QJN7WNkRHD+q4==GkBPp5=0w@mail.gmail.com>
Subject: Re: TASK_SIZE for !MMU
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Cc: Greg Ungerer <gerg@uclinux.org>, Rabin Vincent <rabin@rab.in>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, linux-m32r@ml.linux-m32r.org, linux-c6x-dev@linux-c6x.org, microblaze-uclinux@itee.uq.edu.au, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Sascha Hauer <kernel@pengutronix.de>, "uclinux-dist-devel@blackfin.uclinux.org" <uclinux-dist-devel@blackfin.uclinux.org>, Andrew Morton <akpm@linux-foundation.org>, panchaxari <panchaxari.prasannamurthy@linaro.org>, Linus Walleij <linus.walleij@linaro.org>

On Tue, Jun 3, 2014 at 4:11 PM, Uwe Kleine-K=C3=B6nig
<u.kleine-koenig@pengutronix.de> wrote:
>> I did that same change for m68k in commit cc24c40 ("m68knommu: remove
>> size limit on non-MMU TASK_SIZE"). For similar reasons as you need to
>> now.
> ok.
>
>> >>Thoughts?
>> >The problem is that current linus/master (and also next) doesn't boot o=
n
>> >my ARM-nommu machine because the user string functions (strnlen_user,
>> >strncpy_from_user et al.) refuse to work on strings above TASK_SIZE
>> >which in my case also includes the XIP kernel image.
>>
>> I seem to recall that we were not considering flash or anything else
>> other than RAM when defining that original TASK_SIZE (back many, many
>> years ago). Some of the address checks you list above made some sense
>> if you had everything in RAM (though only upper bounds are checked).
>> The thinking was some checking is better than none I suppose.
> What is the actual meaning of TASK_SIZE? The maximal value of a valid
> userspace address?

Yes

$ git show cc24c40
commit cc24c405949e3d4418a90014d10166679d78141a
Author: Greg Ungerer <gerg@uclinux.org>
Date:   Mon May 24 11:22:05 2010 +1000

    m68knommu: remove size limit on non-MMU TASK_SIZE

    The TASK_SIZE define is used in some places as a limit on the size of
    the virtual address space of a process. On non-MMU systems those addres=
ses
    used in comparison will be physical addresses, and they could be anywhe=
re
    in the 32bit physical address space. So for !CONFIG_MMU systems set the
    TASK_SIZE to the maximum physical address.

    Signed-off-by: Greg Ungerer <gerg@uclinux.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
