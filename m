Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B0E046B039A
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 17:55:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y17so400422007pgh.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 14:55:14 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0109.outbound.protection.outlook.com. [104.47.40.109])
        by mx.google.com with ESMTPS id t11si4858976plm.337.2017.03.14.14.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 14:55:13 -0700 (PDT)
Message-ID: <58C866B6.4040800@cs.rutgers.edu>
Date: Tue, 14 Mar 2017 16:55:02 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v4 05/11] mm: thp: enable thp migration in generic path
References: <201703150534.RFh2ClRg%fengguang.wu@intel.com>
In-Reply-To: <201703150534.RFh2ClRg%fengguang.wu@intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enigB03AAE8FE0FCAA0C5427DDA0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

--------------enigB03AAE8FE0FCAA0C5427DDA0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



On 03/14/2017 04:19 PM, kbuild test robot wrote:
> Hi Naoya,
>
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on next-20170310]
> [cannot apply to v4.11-rc2]
> [if your patch is applied to the wrong git tree, please drop us a note =
to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Zi-Yan/mm-page-migrati=
on-enhancement-for-thp/20170315-042736
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: m68k-sun3_defconfig (attached as .config)
> compiler: m68k-linux-gcc (GCC) 4.9.0
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/s=
bin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=3Dm68k=20
>
> All warnings (new ones prefixed by >>):
>
>    In file included from fs/proc/task_mmu.c:15:0:
>    include/linux/swapops.h: In function 'remove_migration_pmd':
>    include/linux/swapops.h:209:2: warning: 'return' with a value, in fu=
nction returning void
>      return 0;
>      ^
>    include/linux/swapops.h: In function 'swp_entry_to_pmd':

I will remove "return 0;" in next version.

--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -208,7 +208,6 @@ static inline void remove_migration_pmd(struct
page_vma_mapped_walk *pvmw,
                struct page *new)
 {
        BUILD_BUG();
-       return 0;
 }

 static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t
*p) { }


>>> include/linux/swapops.h:223:2: warning: missing braces around initial=
izer [-Wmissing-braces]
>      return (pmd_t){ 0 };
>      ^
>    include/linux/swapops.h:223:2: warning: (near initialization for '(a=
nonymous).pmd') [-Wmissing-braces]

I do not have any warning with gcc 6.3.0. This seems to be a GCC bug
(https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D53119).


--=20
Best Regards,
Yan Zi



--------------enigB03AAE8FE0FCAA0C5427DDA0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJYyGa3AAoJEEGLLxGcTqbMa8sH/0isCTuPro33r5lJ5yWihuLt
nZ7wuV9ugT3L8fkyQJEGHEawuT98/LvJI3uyDv/I8IWlhc2n3tmQts66Y3eTwuKQ
nTZLg9F2GM8xNmWexlUh53NGHLx1iEVG6NcHRGGn6Pq0/daj3czNaI+6DpzlhRXP
JnzUoGLZNDFoJAczO7wbgupuraQZfs9mocdlAbTuyguWz8H1qsV1JmDr7tp/4Dgk
86GwqCscskpQxjRD7BopJ2+VZfD/eL79kvKlzdxPjKWNpSI94kylnLhA7F3Ci2ln
amg/o32TEzIIIKWQma3/RZm9YmaBuoqdy8OMMuAZGpxH/pKf1cYiH0kBufQa+mM=
=0t3C
-----END PGP SIGNATURE-----

--------------enigB03AAE8FE0FCAA0C5427DDA0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
