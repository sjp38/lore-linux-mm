Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE2FF6B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:43:26 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g62so5249000ith.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 06:43:26 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id f135si4573512itc.126.2016.08.23.06.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 06:43:16 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id f6so8028408ith.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 06:43:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160823122119.GK20834@nuc-i3427.alporthouse.com>
References: <20160823072253.26977-1-chris@chris-wilson.co.uk>
 <1471939443.3696.2.camel@linux.intel.com> <20160823120518.GE10980@phenom.ffwll.local>
 <20160823122119.GK20834@nuc-i3427.alporthouse.com>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Tue, 23 Aug 2016 15:43:15 +0200
Message-ID: <CAKMK7uFjtbsareLBGjCWvypybNRVROpkrD-oCDxvnj8B+EkDgQ@mail.gmail.com>
Subject: Re: [PATCH] io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, intel-gfx <intel-gfx@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>

On Tue, Aug 23, 2016 at 2:21 PM, Chris Wilson <chris@chris-wilson.co.uk> wr=
ote:
> On Tue, Aug 23, 2016 at 02:05:18PM +0200, Daniel Vetter wrote:
>> On Tue, Aug 23, 2016 at 11:04:03AM +0300, Joonas Lahtinen wrote:
>> > On ti, 2016-08-23 at 08:22 +0100, Chris Wilson wrote:
>> > > PAGE_KERNEL_IO is an x86-ism. Though it is used to define the pgprot=
_t
>> > > used for the iomapped region, it itself is just PAGE_KERNEL. On all
>> > > other arches, PAGE_KERNEL_IO is undefined so in a general header we =
must
>> > > refrain from using it.
>> > >
>> >
>> > There is;
>> >
>> > #define __PAGE_KERNEL_IO           (__PAGE_KERNEL)
>> >
>> > So no functional change, but will compile on all archs.
>> >
>> > Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
>>
>> Still not happy:
>>
>>   CC      drivers/gpio/gpiolib-of.o
>> In file included from drivers/gpio/gpiolib-of.c:19:0:
>> ./include/linux/io-mapping.h: In function =E2=80=98io_mapping_init_wc=E2=
=80=99:
>> ./include/linux/io-mapping.h:125:16: error: implicit declaration of func=
tion =E2=80=98pgprot_writecombine=E2=80=99 [-Werror=3Dimplicit-function-dec=
laration]
>>   iomap->prot =3D pgprot_writecombine(PAGE_KERNEL);
>>                 ^~~~~~~~~~~~~~~~~~~
>> ./include/linux/io-mapping.h:125:36: error: =E2=80=98PAGE_KERNEL=E2=80=
=99 undeclared (first use in this function)
>>   iomap->prot =3D pgprot_writecombine(PAGE_KERNEL);
>>                                     ^~~~~~~~~~~
>
> That was pulled in by the x86 headers,
>
> #include <asm/pgtable.h>

Can you pls respin?

Thanks, Daniel
--=20
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
