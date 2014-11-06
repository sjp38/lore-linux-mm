Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id D306E6B0071
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 20:00:34 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so1988182iec.35
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 17:00:34 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id o8si7548206ioe.0.2014.11.05.17.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 17:00:33 -0800 (PST)
Received: by mail-ig0-f173.google.com with SMTP id r10so9862874igi.12
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 17:00:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <xa1tsihxwblf.fsf@mina86.com>
References: <CADtm3G7DtGkvPk36Fiunwen8grw-94V6=iv82iusGumfNJkn-g@mail.gmail.com>
	<xa1tlhnq7ga7.fsf@mina86.com>
	<CADtm3G7bU6Y2aKco5Vb81KSqsy=FH9zmdDJm=Tixjoep1YeJ7Q@mail.gmail.com>
	<CAL1ERfMYmQcQ_sX7E0HC2bXmC-imh4T-7Q4nBVQRXkQSaTjvQQ@mail.gmail.com>
	<xa1tsihxwblf.fsf@mina86.com>
Date: Thu, 6 Nov 2014 09:00:33 +0800
Message-ID: <CAL1ERfMk+rhd=-MaLC2VVj61-T17_SVgKL4=Z_okhEYktFJ+tQ@mail.gmail.com>
Subject: Re: CMA alignment question
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org, Laura Abbott <lauraa@codeaurora.org>, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Brian Norris <computersforpeace@gmail.com>

On Thu, Nov 6, 2014 at 6:01 AM, Michal Nazarewicz <mina86@mina86.com> wrote=
:
>> On Tue, Nov 04 2014, Gregory Fong wrote:
>>> The alignment in cma_alloc() is done w.r.t. the bitmap.  This is a
>>> problem when, for example:
>>>
>>> - a device requires 16M (order 12) alignment
>>> - the CMA region is not 16 M aligned
>
> On Wed, Nov 05 2014, Weijie Yang wrote:
>> I think the device driver should ensure that situation could not occur,
>> by assign suitable alignment parameter in cma_declare_contiguous().
>
> What about default CMA area? Besides, I think principle of least
> surprise applies here and alignment should be physical.

I agree the current code doesn't handle this issue properly.
However, I prefer to add specific usage to CMA interface rather than
modify the cma code, Because the latter hide the issue and could waste
memory.

> --
> Best regards,                                         _     _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
> ..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz =
   (o o)
> ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
