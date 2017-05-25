Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41F486B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 19:35:54 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l78so606491iod.4
        for <linux-mm@kvack.org>; Thu, 25 May 2017 16:35:54 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0097.outbound.protection.outlook.com. [104.47.33.97])
        by mx.google.com with ESMTPS id v12si98269ite.91.2017.05.25.16.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 May 2017 16:35:53 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v6 05/10] mm: thp: enable thp migration in generic path
Date: Thu, 25 May 2017 19:35:40 -0400
Message-ID: <F8017E2F-74FB-4D9F-9900-D4D1085E1F30@cs.rutgers.edu>
In-Reply-To: <20170525154328.61a2b2ceef37183895d5ce43@linux-foundation.org>
References: <201705260111.PCjyEyr4%fengguang.wu@intel.com>
 <138B8C07-2A41-40AA-9B4C-5F85FEFD6F0D@cs.rutgers.edu>
 <20170525154328.61a2b2ceef37183895d5ce43@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_06FFC045-7629-46BF-8F9F-5953B6063C72_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_06FFC045-7629-46BF-8F9F-5953B6063C72_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 25 May 2017, at 18:43, Andrew Morton wrote:

> On Thu, 25 May 2017 13:19:54 -0400 "Zi Yan" <zi.yan@cs.rutgers.edu> wro=
te:
>
>> On 25 May 2017, at 13:06, kbuild test robot wrote:
>>
>>> Hi Zi,
>>>
>>> [auto build test WARNING on mmotm/master]
>>> [also build test WARNING on v4.12-rc2 next-20170525]
>>> [if your patch is applied to the wrong git tree, please drop us a not=
e to help improve the system]
>>>
>>> url:    https://github.com/0day-ci/linux/commits/Zi-Yan/mm-page-migra=
tion-enhancement-for-thp/20170526-003749
>>> base:   git://git.cmpxchg.org/linux-mmotm.git master
>>> config: i386-randconfig-x016-201721 (attached as .config)
>>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>>> reproduce:
>>>         # save the attached .config to linux build tree
>>>         make ARCH=3Di386
>>>
>>> All warnings (new ones prefixed by >>):
>>>
>>>    In file included from fs/proc/task_mmu.c:15:0:
>>>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
>>>>> include/linux/swapops.h:222:16: warning: missing braces around init=
ializer [-Wmissing-braces]
>>>      return (pmd_t){{ 0 }};
>>>                    ^
>>
>> The braces are added to eliminate the warning from "m68k-linux-gcc (GC=
C) 4.9.0",
>> which has the bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D5311=
9.
>
> I think we'd prefer to have a warning on m68k than on i386!  Is there
> something smarter we can do here?

I will remove the braces in the next version.

The bug is present in gcc 4.8 and 4.9 and m68k has newer gcc to use,
so kbuild test robot needs to upgrade its m68k gcc (maybe it has done it)=
=2E

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_06FFC045-7629-46BF-8F9F-5953B6063C72_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZJ2pNAAoJEEGLLxGcTqbM0DUH/RvmgXFHm3AigVAoY+JcuKyy
iqOVtPyYAo7IoKWvbWwYpMN0buMkBfaCqG5Ld+tkNvI6nXob3wxYihFSiaZNtUEQ
axGjLVjy6wdGb+cvvi1dA6dZYAtsrENYhY8d61t9tY94pOgfc+LHIRHogjobPdaQ
hnacU/jWfc4cRr4HgUllFgT082BFQKEEv7SJJjVcTRv2D2KiTqAPk7kINAZPWN02
VyLLrNS0mZJvl3DXlpd+wPU1crgNUAW9WcF39EH56OCbgD1Fg3X0jF+xolufKd64
61KL5na4B+bZ9zuZeOb0l37xTr3/hmsb/0ERm+yO6kjucWTdXx2gf+diNY2fnCc=
=JDh7
-----END PGP SIGNATURE-----

--=_MailMate_06FFC045-7629-46BF-8F9F-5953B6063C72_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
