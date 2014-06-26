Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id A841F6B008C
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 11:58:04 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so3996979wes.40
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 08:58:02 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id hh4si13135219wib.9.2014.06.26.08.57.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 08:57:52 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so3899607wgh.18
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 08:57:50 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC] CMA page migration failure due to buffers on bh_lru
In-Reply-To: <53A8D092.4040801@lge.com>
References: <53A8D092.4040801@lge.com>
Date: Thu, 26 Jun 2014 17:57:45 +0200
Message-ID: <xa1td2dvmznq.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>

On Tue, Jun 24 2014, Gioh Kim <gioh.kim@lge.com> wrote:
> Hello,
>
> I am trying to apply CMA feature for my platform.
> My kernel version, 3.10.x, is not allocating memory from CMA area so that=
 I applied
> a Joonsoo Kim's patch (https://lkml.org/lkml/2014/5/28/64).
> Now my platform can use CMA area effectively.
>
> But I have many failures to allocate memory from CMA area.
> I found the same situation to Laura Abbott's patch descrbing,
> https://lkml.org/lkml/2012/8/31/313,
> that releases buffer-heads attached at CPU's LRU list.
>
> If Joonsoo's patch is applied and/or CMA feature is applied more and more,
> buffer-heads problem is going to be serious definitely.
>
> Please look into the Laura's patch again.
> I think it must be applied with Joonsoo's patch.

Just to make sure I understood you correctly, you're saying Laura's
patch at <https://lkml.org/lkml/2012/8/31/313> fixes your issue?

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
