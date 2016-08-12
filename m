Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07F196B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 21:31:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so1730431wmz.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 18:31:23 -0700 (PDT)
Received: from outbound1.eu.mailhop.org (outbound1.eu.mailhop.org. [52.28.251.132])
        by mx.google.com with ESMTPS id a64si183598wmc.86.2016.08.11.18.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 18:31:22 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [mmotm:master 70/106] arch/x86/kernel/process.c:511:9: error: implicit declaration of function 'randomize_page'
From: Jason Cooper <jason@lakedaemon.net>
In-Reply-To: <201608120949.AtRXkB4G%fengguang.wu@intel.com>
Date: Thu, 11 Aug 2016 21:31:15 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <65DEA104-339F-4EB0-9E98-8959D28BA245@lakedaemon.net>
References: <201608120949.AtRXkB4G%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Andrew,=20

I think you have v1 and v2 of the randomize page patches in your stack. Coul=
d you drop v1 please?

thx,

Jason.

> On Aug 11, 2016, at 21:19, kbuild test robot <fengguang.wu@intel.com> wrot=
e:
>=20
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   304bec1b1d331282b76d92a1487902ce1f158337
> commit: 216e0dbb5aab2e588b1f9de3b434015aa1c412f7 [70/106] x86: use simpler=
 API for random address requests
> config: i386-tinyconfig (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>        git checkout 216e0dbb5aab2e588b1f9de3b434015aa1c412f7
>        # save the attached .config to linux build tree
>        make ARCH=3Di386=20
>=20
> Note: the mmotm/master HEAD 304bec1b1d331282b76d92a1487902ce1f158337 build=
s fine.
>      It only hurts bisectibility.
>=20
> All errors (new ones prefixed by >>):
>=20
>   arch/x86/kernel/process.c: In function 'arch_randomize_brk':
>>> arch/x86/kernel/process.c:511:9: error: implicit declaration of function=
 'randomize_page' [-Werror=3Dimplicit-function-declaration]
>     return randomize_page(mm->brk, 0x02000000);
>            ^~~~~~~~~~~~~~
>   cc1: some warnings being treated as errors
>=20
> vim +/randomize_page +511 arch/x86/kernel/process.c
>=20
>   505            sp -=3D get_random_int() % 8192;
>   506        return sp & ~0xf;
>   507    }
>   508   =20
>   509    unsigned long arch_randomize_brk(struct mm_struct *mm)
>   510    {
>> 511        return randomize_page(mm->brk, 0x02000000);
>   512    }
>   513   =20
>   514    /*
>=20
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Cen=
ter
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporat=
ion
> <.config.gz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
