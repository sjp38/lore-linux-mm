Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC6F2806D8
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 06:54:31 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d8so18135477pgt.1
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 03:54:31 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0133.outbound.protection.outlook.com. [104.47.42.133])
        by mx.google.com with ESMTPS id 34si1722170plz.823.2017.09.07.03.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Sep 2017 03:54:30 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [mmotm:master 143/319] include/linux/swapops.h:224:16: error:
 empty scalar initializer
Date: Thu, 07 Sep 2017 06:54:20 -0400
Message-ID: <A8D9CC43-5D31-46D7-B049-A88A027835EA@cs.rutgers.edu>
In-Reply-To: <20170906215017.a95d6bc457a7c0327e6872c3@linux-foundation.org>
References: <201709071117.XZRVgPlb%fengguang.wu@intel.com>
 <20170906215017.a95d6bc457a7c0327e6872c3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_A37E68E7-1CA3-4821-A7DC-4272B5B21D93_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_A37E68E7-1CA3-4821-A7DC-4272B5B21D93_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 7 Sep 2017, at 0:50, Andrew Morton wrote:

> On Thu, 7 Sep 2017 11:37:19 +0800 kbuild test robot <fengguang.wu@intel=
=2Ecom> wrote:
>
>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>> head:   5e52cc028671694cd84e649e0a43c99a53b1fea1
>> commit: ebacb62aac74e6683be1031fed6bfd029732d155 [143/319] mm-thp-enab=
le-thp-migration-in-generic-path-fix-fix-fix
>> config: arm-at91_dt_defconfig (attached as .config)
>> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>>         wget https://na01.safelinks.protection.outlook.com/?url=3Dhttp=
s%3A%2F%2Fraw.githubusercontent.com%2Fintel%2Flkp-tests%2Fmaster%2Fsbin%2=
Fmake.cross&data=3D02%7C01%7Czi.yan%40cs.rutgers.edu%7C6ac33fb5121b4518eb=
6308d4f5abf197%7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C6364035662279=
96732&sdata=3DeSBomrixcY9RpH%2BkKovnCQmHlpaOcWXaZ02J0cX%2FQlg%3D&reserved=
=3D0 -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         git checkout ebacb62aac74e6683be1031fed6bfd029732d155
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=3Darm
>>
>> All errors (new ones prefixed by >>):
>>
>>    In file included from fs/proc/task_mmu.c:15:0:
>>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
>>>> include/linux/swapops.h:224:16: error: empty scalar initializer
>>      return (pmd_t){};
>>                    ^
>>    include/linux/swapops.h:224:16: note: (near initialization for '(an=
onymous)')
>>
>> vim +224 include/linux/swapops.h
>>
>>    221	=

>>    222	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>>    223	{
>>> 224		return (pmd_t){};
>>    225	}
>>    226	=

>
> Sigh, I tried.
>
> Zi Yan, we're going to need to find a fix for this.  Rapidly, please.


Hi Andrew,

Why cannot we use __pmd(0) instead? My sparc32 fix is in 4.13 now.
commit is 9157259d16a8ee8116a98d32f29b797689327e8d.

It should be OK to use __pmd(0). Is there any other arch not having __pmd=
()?

Thanks.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_A37E68E7-1CA3-4821-A7DC-4272B5B21D93_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZsSVcAAoJEEGLLxGcTqbMxJUIAKWotPv3yGPJBW0h1sduo/3L
1zH+Ke347FmDDXTi1dFM13YdIgA9W4CwuTPP5C2WLHYlIqPgs24aR6fykQPP8K/y
JTGVAjJKkIOxSlyi49gIm0OtAnnkCBPvExu0I6QeNEllRG1l3yC/B+3eoXXy7dar
A1rtYC7LlPGSMKoO6HsMLGtSbn0ocKh1ctWnH8GzBJTwJ1a0IhXBlY13YJ5l39ke
SKftWyZBFEqDLw5Ox2i75qGbnxJGyEz4AfwabKEagT19fXEBgZAYajHqRP4S8LQK
7LgwU/LoJhjNCliJVX+h5hPkU/LwrJYmVgpKn1r4kaJgPhLmWqFr52kzAjAsvwg=
=Zkm2
-----END PGP SIGNATURE-----

--=_MailMate_A37E68E7-1CA3-4821-A7DC-4272B5B21D93_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
