Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 30B816B006C
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 14:21:42 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so2855356wiw.8
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 11:21:41 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id y6si13412857wje.125.2014.12.18.11.21.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 11:21:39 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id y19so2500996wgg.35
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 11:21:39 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] CMA: add the amount of cma memory in meminfo
In-Reply-To: <548E3B5E.6050805@huawei.com>
References: <547FCCE9.2020600@huawei.com> <xa1ty4qm9eq7.fsf@mina86.com> <548E3B5E.6050805@huawei.com>
Date: Thu, 18 Dec 2014 20:21:31 +0100
Message-ID: <xa1tegrwsr0k.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, Dec 15 2014, Xishi Qiu <qiuxishi@huawei.com> wrote:
> The "mere white-space change" you said a few days ago=EF=BC=8Chow about c=
hange like this
> ", nid, K(...)" -> ",nid, K(xxx)"?

If space is all you're changing, I wouldn't change it.

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
