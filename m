Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 19E436B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 17:01:53 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id gd6so1526396lab.6
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 14:01:52 -0800 (PST)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id um10si8346694lbb.117.2014.11.05.14.01.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 14:01:52 -0800 (PST)
Received: by mail-la0-f41.google.com with SMTP id s18so1548132lam.28
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 14:01:51 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: CMA alignment question
In-Reply-To: <CAL1ERfMYmQcQ_sX7E0HC2bXmC-imh4T-7Q4nBVQRXkQSaTjvQQ@mail.gmail.com>
References: <CADtm3G7DtGkvPk36Fiunwen8grw-94V6=iv82iusGumfNJkn-g@mail.gmail.com> <xa1tlhnq7ga7.fsf@mina86.com> <CADtm3G7bU6Y2aKco5Vb81KSqsy=FH9zmdDJm=Tixjoep1YeJ7Q@mail.gmail.com> <CAL1ERfMYmQcQ_sX7E0HC2bXmC-imh4T-7Q4nBVQRXkQSaTjvQQ@mail.gmail.com>
Date: Wed, 05 Nov 2014 23:01:48 +0100
Message-ID: <xa1tsihxwblf.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>, Gregory Fong <gregory.0xf0@gmail.com>
Cc: linux-mm@kvack.org, Laura Abbott <lauraa@codeaurora.org>, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Brian Norris <computersforpeace@gmail.com>

> On Tue, Nov 04 2014, Gregory Fong wrote:
>> The alignment in cma_alloc() is done w.r.t. the bitmap.  This is a
>> problem when, for example:
>>
>> - a device requires 16M (order 12) alignment
>> - the CMA region is not 16 M aligned

On Wed, Nov 05 2014, Weijie Yang wrote:
> I think the device driver should ensure that situation could not occur,
> by assign suitable alignment parameter in cma_declare_contiguous().

What about default CMA area? Besides, I think principle of least
surprise applies here and alignment should be physical.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
