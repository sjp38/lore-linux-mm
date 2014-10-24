Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id EA6F76B006C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 12:34:52 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so2854779lbv.38
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:34:52 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com. [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id ao5si7780279lbc.58.2014.10.24.09.34.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 09:34:51 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id f15so1574387lbj.41
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:34:50 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/4] mm: cma: Don't crash on allocation if CMA area can't be activated
In-Reply-To: <1463193.4qGZjcvNod@avalon>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414074828-4488-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <xa1tmw8mlobz.fsf@mina86.com> <1463193.4qGZjcvNod@avalon>
Date: Fri, 24 Oct 2014 18:34:46 +0200
Message-ID: <xa1tfved2zq1.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

> On Thursday 23 October 2014 18:53:36 Michal Nazarewicz wrote:
>> As a matter of fact, this is present in kernels earlier than 3.17 but in
>> the 3.17 the code has been moved from drivers/base/dma-contiguous.c to
>> mm/cma.c so this might require separate stable patch.

On Fri, Oct 24 2014, Laurent Pinchart <laurent.pinchart@ideasonboard.com> w=
rote:
> That could be done, but I'm not sure if it's really worth it. The bug onl=
y=20
> occurs when the CMA zone activation fails. I've ran into that case due to=
 a=20
> bug introduced in v3.18-rc1, but this shouldn't be the case for older ker=
nel=20
> versions.

Fair enough.

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
