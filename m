Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 494C76B02B4
	for <linux-mm@kvack.org>; Thu, 25 May 2017 13:20:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e79so130739224ioi.6
        for <linux-mm@kvack.org>; Thu, 25 May 2017 10:20:04 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0090.outbound.protection.outlook.com. [104.47.33.90])
        by mx.google.com with ESMTPS id i199si27305268ioi.249.2017.05.25.10.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 May 2017 10:20:03 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v6 05/10] mm: thp: enable thp migration in generic path
Date: Thu, 25 May 2017 13:19:54 -0400
Message-ID: <138B8C07-2A41-40AA-9B4C-5F85FEFD6F0D@cs.rutgers.edu>
In-Reply-To: <201705260111.PCjyEyr4%fengguang.wu@intel.com>
References: <201705260111.PCjyEyr4%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_E51C2169-D7D5-4975-851F-06ABA7244AD4_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_E51C2169-D7D5-4975-851F-06ABA7244AD4_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 25 May 2017, at 13:06, kbuild test robot wrote:

> Hi Zi,
>
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.12-rc2 next-20170525]
> [if your patch is applied to the wrong git tree, please drop us a note =
to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Zi-Yan/mm-page-migrati=
on-enhancement-for-thp/20170526-003749
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-x016-201721 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=3Di386
>
> All warnings (new ones prefixed by >>):
>
>    In file included from fs/proc/task_mmu.c:15:0:
>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
>>> include/linux/swapops.h:222:16: warning: missing braces around initia=
lizer [-Wmissing-braces]
>      return (pmd_t){{ 0 }};
>                    ^

The braces are added to eliminate the warning from "m68k-linux-gcc (GCC) =
4.9.0",
which has the bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D53119.

--
Best Regards
Yan Zi

--=_MailMate_E51C2169-D7D5-4975-851F-06ABA7244AD4_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZJxI6AAoJEEGLLxGcTqbMW1UH/3oA1s1DS6YdizffeO1cMJ+w
78k8XQMbsR1uEyj2WHFlAyte/Lw3hEnYo1dsRyV/ZEgPdIJ45nTED5YEceWYfKCi
wchJRQCHtJVmYRP8oIEJqTelKeDvYa8kANTm+BkfE5VMCES0CalyaDD1ypC4Qetz
RreUt5lf5Qjg+zufZWfoO5Wx9/gzP+0CbTdyHSOj5OaQKd/UAtDX0RsmYsuMpTbY
DfwYqVxhYKHj8N9sgwIljeSiX45ZYj6ZHiBWv1OcnviHIl3u1n37OZJ9T3utC06y
oYGo/JnVq84OM2jm8/Y1UrCE7TYgR+48YBM9tkDBfgiFXqXZc3UnWKcxHjD++zY=
=EJ2z
-----END PGP SIGNATURE-----

--=_MailMate_E51C2169-D7D5-4975-851F-06ABA7244AD4_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
