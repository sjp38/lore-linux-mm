Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 106716B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 20:25:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m1so800978pgd.13
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:25:17 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q188si3894321pfb.323.2017.03.28.17.25.15
        for <linux-mm@kvack.org>;
        Tue, 28 Mar 2017 17:25:16 -0700 (PDT)
Date: Wed, 29 Mar 2017 09:20:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC]mm/zsmalloc,: trigger BUG_ON in function zs_map_object.
Message-ID: <20170329002029.GA18979@bbox>
References: <e8aa282e-ad53-bfb8-2b01-33d2779f247a@huawei.com>
MIME-Version: 1.0
In-Reply-To: <e8aa282e-ad53-bfb8-2b01-33d2779f247a@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Hello,

On Tue, Mar 28, 2017 at 03:20:22PM +0800, Yisheng Xie wrote:
> Hi, all,
>=20
> We had backport the no-lru migration to linux-4.1, meanwhile change the
> ZS=5FMAX=5FZSPAGE=5FORDER to 3. Then we met a BUG=5FON(!page[1]).

Hmm, I don't know how you backported.

There isn't any problem with default ZS=5FMAX=5FZSPAGE=5FORDER. Right?
So, it happens only if you changed it to 3?

Could you tell me what is your base kernel? and what zram/zsmalloc
version(ie, from what kernel version) you backported to your
base kernel?

>=20
> It rarely happen, and presently, what I get is:
> [6823.316528s]obj=3Da160701f, obj=5Fidx=3D15, class{size:2176,objs=5Fper=
=5Fzspage:15,pages=5Fper=5Fzspage:8}
> [...]
> [6823.316619s]BUG: failure at /home/ethan/kernel/linux-4.1/mm/zsmalloc.c:=
1458/zs=5Fmap=5Fobject()! ----> BUG=5FON(!page[1])
>=20
> It seems that we have allocated an object from a ZS=5FFULL group?
> (Actually=EF=BC=8C I do not get the inuse number of this zspage, which I =
am trying to.)
> And presently, I can not find why it happened. Any idea about it?

Although it happens rarely, always above same symptom once it happens?

>=20
> Any comment is more than welcome!
>=20
> Thanks
> Yisheng Xie
>=20
>=20
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
