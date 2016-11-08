Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A55E6B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 20:42:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so59030550pfk.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 17:42:23 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id r29si28159217pfe.133.2016.11.07.17.42.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 17:42:22 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 12/12] mm: memory_hotplug: memory hotremove supports
 thp migration
Date: Tue, 8 Nov 2016 01:36:03 +0000
Message-ID: <20161108013602.GA20317@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-13-git-send-email-n-horiguchi@ah.jp.nec.com>
 <201611080850.MhSq3cNm%fengguang.wu@intel.com>
In-Reply-To: <201611080850.MhSq3cNm%fengguang.wu@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0E2046DFEC84F54C87A63C648F74FE24@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Nov 08, 2016 at 08:30:10AM +0800, kbuild test robot wrote:
> Hi Naoya,
>=20
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on next-20161028]
> [cannot apply to v4.9-rc4]
> [if your patch is applied to the wrong git tree, please drop us a note to=
 help improve the system]
>=20
> url:    https://github.com/0day-ci/linux/commits/Naoya-Horiguchi/mm-x86-m=
ove-_PAGE_SWP_SOFT_DIRTY-from-bit-7-to-bit-6/20161108-080615
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-x003-201645 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=3Dx86_64=20
>=20
> All warnings (new ones prefixed by >>):
>=20
>    mm/memory_hotplug.c: In function 'try_offline_node':
>    mm/memory_hotplug.c:2131:6: warning: unused variable 'i' [-Wunused-var=
iable]
>      int i;
>          ^
>    In file included from include/uapi/linux/stddef.h:1:0,
>                     from include/linux/stddef.h:4,
>                     from mm/memory_hotplug.c:7:

This seems unrelated to my patchset, but the fix is easy.
I'll post a separate patch later.

>    mm/memory_hotplug.c: In function 'new_node_page':
>    include/linux/compiler.h:518:38: error: call to '__compiletime_assert_=
1575' declared with attribute error: BUILD_BUG failed
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>                                          ^
>    include/linux/compiler.h:160:16: note: in definition of macro '__trace=
_if'
>       ______r =3D !!(cond);     \
>                    ^~~~
> >> mm/memory_hotplug.c:1575:2: note: in expansion of macro 'if'
>      if (new_page && order =3D=3D HPAGE_PMD_ORDER)
>      ^~
>    include/linux/compiler.h:506:2: note: in expansion of macro '__compile=
time_assert'
>      __compiletime_assert(condition, msg, prefix, suffix)
>      ^~~~~~~~~~~~~~~~~~~~
>    include/linux/compiler.h:518:2: note: in expansion of macro '_compilet=
ime_assert'
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>      ^~~~~~~~~~~~~~~~~~~
>    include/linux/bug.h:54:37: note: in expansion of macro 'compiletime_as=
sert'
>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                         ^~~~~~~~~~~~~~~~~~
>    include/linux/bug.h:88:21: note: in expansion of macro 'BUILD_BUG_ON_M=
SG'
>     #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>                         ^~~~~~~~~~~~~~~~
>    include/linux/huge_mm.h:181:28: note: in expansion of macro 'BUILD_BUG=
'
>     #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>                                ^~~~~~~~~
>    include/linux/huge_mm.h:56:26: note: in expansion of macro 'HPAGE_PMD_=
SHIFT'
>     #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
>                              ^~~~~~~~~~~~~~~
>    mm/memory_hotplug.c:1575:27: note: in expansion of macro 'HPAGE_PMD_OR=
DER'
>      if (new_page && order =3D=3D HPAGE_PMD_ORDER)
>                               ^~~~~~~~~~~~~~~

HPAGE_PMD_ORDER is not available in non-thp code now, so let's add
a simple wrapper to access it in generic code.


diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3c252cdef587..b75a9a1bbf3e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -148,6 +148,12 @@ static inline int hpage_nr_pages(struct page *page)
 		return HPAGE_PMD_NR;
 	return 1;
 }
+static inline int hpage_order(struct page *page)
+{
+	if (unlikely(PageTransHuge(page)))
+		return HPAGE_PMD_ORDER;
+	return 0;
+}
=20
 extern int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t orig_pmd);
=20
@@ -183,6 +189,7 @@ static inline bool thp_migration_supported(void)
 #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
=20
 #define hpage_nr_pages(x) 1
+#define hpage_order(x) 0
=20
 #define transparent_hugepage_enabled(__vma) 0
=20
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a9c3fe1b55ea..d612a75ceec4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1555,7 +1555,7 @@ static struct page *new_node_page(struct page *page, =
unsigned long private,
 					next_node_in(nid, nmask));
=20
 	if (thp_migration_supported() && PageTransHuge(page)) {
-		order =3D HPAGE_PMD_ORDER;
+		order =3D hpage_order(page);
 		gfp_mask |=3D GFP_TRANSHUGE;
 	}
=20
@@ -1572,7 +1572,7 @@ static struct page *new_node_page(struct page *page, =
unsigned long private,
 		new_page =3D __alloc_pages(gfp_mask, order,
 					node_zonelist(nid, gfp_mask));
=20
-	if (new_page && order =3D=3D HPAGE_PMD_ORDER)
+	if (new_page && order =3D=3D hpage_order(page))
 		prep_transhuge_page(new_page);
=20
 	return new_page;
@@ -1606,7 +1606,7 @@ do_migrate_range(unsigned long start_pfn, unsigned lo=
ng end_pfn)
 			continue;
 		} else if (thp_migration_supported() && PageTransHuge(page))
 			pfn =3D page_to_pfn(compound_head(page))
-				+ HPAGE_PMD_NR - 1;
+				+ hpage_nr_pages(page) - 1;
=20
 		if (!get_page_unless_zero(page))
 			continue;

These changes are applied in the next version.

Thanks,
Naoya Horiguchi

>=20
> vim +/if +1575 mm/memory_hotplug.c
>=20
>   1559			gfp_mask |=3D GFP_TRANSHUGE;
>   1560		}
>   1561=09
>   1562		node_clear(nid, nmask);
>   1563=09
>   1564		if (PageHighMem(page)
>   1565		    || (zone_idx(page_zone(page)) =3D=3D ZONE_MOVABLE))
>   1566			gfp_mask |=3D __GFP_HIGHMEM;
>   1567=09
>   1568		if (!nodes_empty(nmask))
>   1569			new_page =3D __alloc_pages_nodemask(gfp_mask, order,
>   1570						node_zonelist(nid, gfp_mask), &nmask);
>   1571		if (!new_page)
>   1572			new_page =3D __alloc_pages(gfp_mask, order,
>   1573						node_zonelist(nid, gfp_mask));
>   1574=09
> > 1575		if (new_page && order =3D=3D HPAGE_PMD_ORDER)
>   1576			prep_transhuge_page(new_page);
>   1577=09
>   1578		return new_page;
>   1579	}
>   1580=09
>   1581	#define NR_OFFLINE_AT_ONCE_PAGES	(256)
>   1582	static int
>   1583	do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>=20
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter
> https://lists.01.org/pipermail/kbuild-all                   Intel Corpora=
tion

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
