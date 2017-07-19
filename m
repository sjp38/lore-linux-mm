Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 657596B0292
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 14:39:54 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q1so2206675qkb.3
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:39:54 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0116.outbound.protection.outlook.com. [104.47.33.116])
        by mx.google.com with ESMTPS id l67si481414qte.403.2017.07.19.11.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 11:39:53 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v9 05/10] mm: thp: enable thp migration in generic path
Date: Wed, 19 Jul 2017 14:39:43 -0400
Message-ID: <A5D98DDB-2295-467D-8368-D0A037CC2DC7@cs.rutgers.edu>
In-Reply-To: <201707191504.G4xCE7El%fengguang.wu@intel.com>
References: <201707191504.G4xCE7El%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_9BA031C3-4E34-4828-991B-95D947D300EA_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_9BA031C3-4E34-4828-991B-95D947D300EA_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 19 Jul 2017, at 4:04, kbuild test robot wrote:

> Hi Zi,
>
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.13-rc1 next-20170718]
> [if your patch is applied to the wrong git tree, please drop us a note =
to help improve the system]
>
> url:    https://na01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2=
F%2Fgithub.com%2F0day-ci%2Flinux%2Fcommits%2FZi-Yan%2Fmm-page-migration-e=
nhancement-for-thp%2F20170718-095519&data=3D02%7C01%7Czi.yan%40cs.rutgers=
=2Eedu%7Ca711ac47d4c0436ef66f08d4ce7cf30c%7Cb92d2b234d35447093ff69aca6632=
ffe%7C1%7C0%7C636360483431631457&sdata=3DNpxRpWbxe6o56xDJYpw1K6wgQo11IPCA=
bG2tE8l%2BU6E%3D&reserved=3D0
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: xtensa-common_defconfig (attached as .config)
> compiler: xtensa-linux-gcc (GCC) 4.9.0
> reproduce:
>         wget https://na01.safelinks.protection.outlook.com/?url=3Dhttps=
%3A%2F%2Fraw.githubusercontent.com%2F01org%2Flkp-tests%2Fmaster%2Fsbin%2F=
make.cross&data=3D02%7C01%7Czi.yan%40cs.rutgers.edu%7Ca711ac47d4c0436ef66=
f08d4ce7cf30c%7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C63636048343163=
1457&sdata=3DrBCfu0xUg3v%2B8r%2Be2tsiqRcqw%2FEZSTa4OtF0hU%2FqMbc%3D&reser=
ved=3D0 -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=3Dxtensa
>
> All warnings (new ones prefixed by >>):
>
>    In file included from mm/vmscan.c:55:0:
>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
>>> include/linux/swapops.h:220:2: warning: missing braces around initial=
izer [-Wmissing-braces]
>      return (pmd_t){ 0 };
>      ^
>    include/linux/swapops.h:220:2: warning: (near initialization for '(a=
nonymous).pud') [-Wmissing-braces]
>
> vim +220 include/linux/swapops.h
>
>    217	=

>    218	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>    219	{
>> 220		return (pmd_t){ 0 };
>    221	}
>    222	=


It is a GCC 4.9.0 bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D531=
19

Upgrading GCC can get rid of this warning.

--
Best Regards
Yan Zi

--=_MailMate_9BA031C3-4E34-4828-991B-95D947D300EA_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZb6dvAAoJEEGLLxGcTqbMbcIIAKIkYbAJfMBbdUiQzsQ7erBR
+i1hWlMYX7cFZhn4xLlncyKIUcanhnu59ZbDlyAnhMgriUoKrqFPtOYNZQg82ZME
3i3GxQU5RYt8cavwE+64xQ7XpKwpB/Bi8tYaiimzb3MiCaXV5PdhYOosjnFTubXW
KTOrr6dTVFmT2PrCqG1M1DcWUul925Q9+7BraroYwBAU5xW50M2EGob65Oh4xcJU
8MZ1uw+p0oDbKqCCLTwPsccOr6WbmBsTUSu7F5kBmETD1FGnFV5mP+Z8pNaZhvS5
zJSeeEb5CfUwi7wGiecNEXbbW8OdoD/gvdMuEj+SwStvL2mHm4D/vF1LAIJ5UW8=
=vSHK
-----END PGP SIGNATURE-----

--=_MailMate_9BA031C3-4E34-4828-991B-95D947D300EA_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
