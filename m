Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA6CE6B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 10:16:12 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h14so39579812ioh.0
        for <linux-mm@kvack.org>; Mon, 29 May 2017 07:16:12 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0116.outbound.protection.outlook.com. [104.47.33.116])
        by mx.google.com with ESMTPS id z8si9407135iod.184.2017.05.29.07.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 May 2017 07:16:11 -0700 (PDT)
Subject: Re: [PATCH v6 05/10] mm: thp: enable thp migration in generic path
From: Zi Yan <zi.yan@cs.rutgers.edu>
References: <201705260111.PCjyEyr4%fengguang.wu@intel.com>
 <138B8C07-2A41-40AA-9B4C-5F85FEFD6F0D@cs.rutgers.edu>
 <20170525154328.61a2b2ceef37183895d5ce43@linux-foundation.org>
 <F8017E2F-74FB-4D9F-9900-D4D1085E1F30@cs.rutgers.edu>
Message-ID: <c1e39aa0-8766-5a17-b5a7-aa76ee89e2c1@cs.rutgers.edu>
Date: Mon, 29 May 2017 10:13:53 -0400
MIME-Version: 1.0
In-Reply-To: <F8017E2F-74FB-4D9F-9900-D4D1085E1F30@cs.rutgers.edu>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="keEUVb32kS2cUfX5SKEVHKMtbIat2U30b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--keEUVb32kS2cUfX5SKEVHKMtbIat2U30b
Content-Type: multipart/mixed; boundary="1f57dV4W1liqtq4gtXitqmT7SpDASoOoG";
 protected-headers="v1"
From: Zi Yan <zi.yan@cs.rutgers.edu>
To: kbuild test robot <lkp@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org,
 n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org,
 vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org,
 khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com
Message-ID: <c1e39aa0-8766-5a17-b5a7-aa76ee89e2c1@cs.rutgers.edu>
Subject: Re: [PATCH v6 05/10] mm: thp: enable thp migration in generic path
References: <201705260111.PCjyEyr4%fengguang.wu@intel.com>
 <138B8C07-2A41-40AA-9B4C-5F85FEFD6F0D@cs.rutgers.edu>
 <20170525154328.61a2b2ceef37183895d5ce43@linux-foundation.org>
 <F8017E2F-74FB-4D9F-9900-D4D1085E1F30@cs.rutgers.edu>
In-Reply-To: <F8017E2F-74FB-4D9F-9900-D4D1085E1F30@cs.rutgers.edu>

--1f57dV4W1liqtq4gtXitqmT7SpDASoOoG
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 05/25/2017 07:35 PM, Zi Yan wrote:
> On 25 May 2017, at 18:43, Andrew Morton wrote:
>=20
>> On Thu, 25 May 2017 13:19:54 -0400 "Zi Yan" <zi.yan@cs.rutgers.edu> wr=
ote:
>>
>>> On 25 May 2017, at 13:06, kbuild test robot wrote:
>>>
>>>> Hi Zi,
>>>>
>>>> [auto build test WARNING on mmotm/master]
>>>> [also build test WARNING on v4.12-rc2 next-20170525]
>>>> [if your patch is applied to the wrong git tree, please drop us a no=
te to help improve the system]
>>>>
>>>> url:    https://github.com/0day-ci/linux/commits/Zi-Yan/mm-page-migr=
ation-enhancement-for-thp/20170526-003749
>>>> base:   git://git.cmpxchg.org/linux-mmotm.git master
>>>> config: i386-randconfig-x016-201721 (attached as .config)
>>>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>>>> reproduce:
>>>>         # save the attached .config to linux build tree
>>>>         make ARCH=3Di386
>>>>
>>>> All warnings (new ones prefixed by >>):
>>>>
>>>>    In file included from fs/proc/task_mmu.c:15:0:
>>>>    include/linux/swapops.h: In function 'swp_entry_to_pmd':
>>>>>> include/linux/swapops.h:222:16: warning: missing braces around ini=
tializer [-Wmissing-braces]
>>>>      return (pmd_t){{ 0 }};
>>>>                    ^
>>>
>>> The braces are added to eliminate the warning from "m68k-linux-gcc (G=
CC) 4.9.0",
>>> which has the bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D531=
19.
>>
>> I think we'd prefer to have a warning on m68k than on i386!  Is there
>> something smarter we can do here?
>=20
> I will remove the braces in the next version.
>=20
> The bug is present in gcc 4.8 and 4.9 and m68k has newer gcc to use,
> so kbuild test robot needs to upgrade its m68k gcc (maybe it has done i=
t).
>

Removed the braces.

---
 arch/x86/include/asm/pgtable_64.h |  2 +
 include/linux/swapops.h           | 69 +++++++++++++++++++++++++++++++-
 mm/huge_memory.c                  | 84 +++++++++++++++++++++++++++++++++=
+++---
 mm/migrate.c                      | 30 +++++++++++++-
 mm/page_vma_mapped.c              | 13 ++++--
 mm/pgtable-generic.c              |  3 +-
 mm/rmap.c                         | 11 +++++
 7 files changed, 200 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgt=
able_64.h
index 45b7a4094de0..eac7f8cf4ae0 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -208,7 +208,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 					 ((type) << (SWP_TYPE_FIRST_BIT)) \
 					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
+#define __pmd_to_swp_entry(pmd)		((swp_entry_t) { pmd_val((pmd)) })
 #define __swp_entry_to_pte(x)		((pte_t) { .pte =3D (x).val })
+#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd =3D (x).val })
=20
 extern int kern_addr_valid(unsigned long addr);
 extern void cleanup_highmap(void);
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 5c3a5f3e7eec..c543c6f25e8f 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -103,7 +103,8 @@ static inline void *swp_to_radix_entry(swp_entry_t en=
try)
 #ifdef CONFIG_MIGRATION
 static inline swp_entry_t make_migration_entry(struct page *page, int wr=
ite)
 {
-	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageLocked(compound_head(page)));
+
 	return swp_entry(write ? SWP_MIGRATION_WRITE : SWP_MIGRATION_READ,
 			page_to_pfn(page));
 }
@@ -126,7 +127,7 @@ static inline struct page *migration_entry_to_page(sw=
p_entry_t entry)
 	 * Any use of migration entries may only occur while the
 	 * corresponding page is locked
 	 */
-	BUG_ON(!PageLocked(p));
+	BUG_ON(!PageLocked(compound_head(p)));
 	return p;
 }
=20
@@ -163,6 +164,70 @@ static inline int is_write_migration_entry(swp_entry=
_t entry)
=20
 #endif
=20
+struct page_vma_mapped_walk;
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+extern void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
+		struct page *page);
+
+extern void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
+		struct page *new);
+
+extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd);
+
+static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
+{
+	swp_entry_t arch_entry;
+
+	arch_entry =3D __pmd_to_swp_entry(pmd);
+	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
+}
+
+static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
+{
+	swp_entry_t arch_entry;
+
+	arch_entry =3D __swp_entry(swp_type(entry), swp_offset(entry));
+	return __swp_entry_to_pmd(arch_entry);
+}
+
+static inline int is_pmd_migration_entry(pmd_t pmd)
+{
+	return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd));
+}
+#else
+static inline void set_pmd_migration_entry(struct page_vma_mapped_walk *=
pvmw,
+		struct page *page)
+{
+	BUILD_BUG();
+}
+
+static inline void remove_migration_pmd(struct page_vma_mapped_walk *pvm=
w,
+		struct page *new)
+{
+	BUILD_BUG();
+}
+
+static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t *=
p) { }
+
+static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
+{
+	BUILD_BUG();
+	return swp_entry(0, 0);
+}
+
+static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
+{
+	BUILD_BUG();
+	return (pmd_t){ 0 };
+}
+
+static inline int is_pmd_migration_entry(pmd_t pmd)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_MEMORY_FAILURE
=20
 extern atomic_long_t num_poisoned_pages __read_mostly;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b137f60bd983..05d8288c3eea 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1635,10 +1635,23 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct v=
m_area_struct *vma,
 		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else {
-		struct page *page =3D pmd_page(orig_pmd);
-		page_remove_rmap(page, true);
-		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-		VM_BUG_ON_PAGE(!PageHead(page), page);
+		struct page *page =3D NULL;
+		int migration =3D 0;
+
+		if (pmd_present(orig_pmd)) {
+			page =3D pmd_page(orig_pmd);
+			page_remove_rmap(page, true);
+			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+			VM_BUG_ON_PAGE(!PageHead(page), page);
+		} else {
+			swp_entry_t entry;
+
+			VM_BUG_ON(!is_pmd_migration_entry(orig_pmd));
+			entry =3D pmd_to_swp_entry(orig_pmd);
+			page =3D pfn_to_page(swp_offset(entry));
+			migration =3D 1;
+		}
+
 		if (PageAnon(page)) {
 			zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
@@ -1647,8 +1660,10 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm=
_area_struct *vma,
 				zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		}
+
 		spin_unlock(ptl);
-		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
+		if (!migration)
+			tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
 	}
 	return 1;
 }
@@ -2688,3 +2703,62 @@ static int __init split_huge_pages_debugfs(void)
 }
 late_initcall(split_huge_pages_debugfs);
 #endif
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
+		struct page *page)
+{
+	struct vm_area_struct *vma =3D pvmw->vma;
+	struct mm_struct *mm =3D vma->vm_mm;
+	unsigned long address =3D pvmw->address;
+	pmd_t pmdval;
+	swp_entry_t entry;
+
+	if (!(pvmw->pmd && !pvmw->pte))
+		return;
+
+	mmu_notifier_invalidate_range_start(mm, address,
+			address + HPAGE_PMD_SIZE);
+
+	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
+	pmdval =3D pmdp_huge_clear_flush(vma, address, pvmw->pmd);
+	if (pmd_dirty(pmdval))
+		set_page_dirty(page);
+	entry =3D make_migration_entry(page, pmd_write(pmdval));
+	pmdval =3D swp_entry_to_pmd(entry);
+	set_pmd_at(mm, address, pvmw->pmd, pmdval);
+	page_remove_rmap(page, true);
+	put_page(page);
+
+	mmu_notifier_invalidate_range_end(mm, address,
+			address + HPAGE_PMD_SIZE);
+}
+
+void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page=
 *new)
+{
+	struct vm_area_struct *vma =3D pvmw->vma;
+	struct mm_struct *mm =3D vma->vm_mm;
+	unsigned long address =3D pvmw->address;
+	unsigned long mmun_start =3D address & HPAGE_PMD_MASK;
+	unsigned long mmun_end =3D mmun_start + HPAGE_PMD_SIZE;
+	pmd_t pmde;
+	swp_entry_t entry;
+
+	if (!(pvmw->pmd && !pvmw->pte))
+		return;
+
+	entry =3D pmd_to_swp_entry(*pvmw->pmd);
+	get_page(new);
+	pmde =3D pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
+	if (is_write_migration_entry(entry))
+		pmde =3D maybe_pmd_mkwrite(pmde, vma);
+
+	flush_cache_range(vma, mmun_start, mmun_end);
+	page_add_anon_rmap(new, vma, mmun_start, true);
+	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
+	flush_tlb_range(vma, mmun_start, mmun_end);
+	if (vma->vm_flags & VM_LOCKED)
+		mlock_vma_page(new);
+	update_mmu_cache_pmd(vma, address, pvmw->pmd);
+}
+#endif
diff --git a/mm/migrate.c b/mm/migrate.c
index 051cc1555d36..37c3eb14cbaa 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -215,6 +215,13 @@ static bool remove_migration_pte(struct page *page, =
struct vm_area_struct *vma,
 			new =3D page - pvmw.page->index +
 				linear_page_index(vma, pvmw.address);
=20
+		/* PMD-mapped THP migration entry */
+		if (!pvmw.pte && pvmw.page) {
+			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
+			remove_migration_pmd(&pvmw, new);
+			continue;
+		}
+
 		get_page(new);
 		pte =3D pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
 		if (pte_swp_soft_dirty(*pvmw.pte))
@@ -329,6 +336,27 @@ void migration_entry_wait_huge(struct vm_area_struct=
 *vma,
 	__migration_entry_wait(mm, pte, ptl);
 }
=20
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
+{
+	spinlock_t *ptl;
+	struct page *page;
+
+	ptl =3D pmd_lock(mm, pmd);
+	if (!is_pmd_migration_entry(*pmd))
+		goto unlock;
+	page =3D migration_entry_to_page(pmd_to_swp_entry(*pmd));
+	if (!get_page_unless_zero(page))
+		goto unlock;
+	spin_unlock(ptl);
+	wait_on_page_locked(page);
+	put_page(page);
+	return;
+unlock:
+	spin_unlock(ptl);
+}
+#endif
+
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
 static bool buffer_migrate_lock_buffers(struct buffer_head *head,
@@ -1087,7 +1115,7 @@ static ICE_noinline int unmap_and_move(new_page_t g=
et_new_page,
 		goto out;
 	}
=20
-	if (unlikely(PageTransHuge(page))) {
+	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
 		lock_page(page);
 		rc =3D split_huge_page(page);
 		unlock_page(page);
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index de9c40d7304a..e209a12d8722 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -137,16 +137,23 @@ bool page_vma_mapped_walk(struct page_vma_mapped_wa=
lk *pvmw)
 	if (!pud_present(*pud))
 		return false;
 	pvmw->pmd =3D pmd_offset(pud, pvmw->address);
-	if (pmd_trans_huge(*pvmw->pmd)) {
+	if (pmd_trans_huge(*pvmw->pmd) || is_pmd_migration_entry(*pvmw->pmd)) {=

 		pvmw->ptl =3D pmd_lock(mm, pvmw->pmd);
-		if (!pmd_present(*pvmw->pmd))
-			return not_found(pvmw);
 		if (likely(pmd_trans_huge(*pvmw->pmd))) {
 			if (pvmw->flags & PVMW_MIGRATION)
 				return not_found(pvmw);
 			if (pmd_page(*pvmw->pmd) !=3D page)
 				return not_found(pvmw);
 			return true;
+		} else if (!pmd_present(*pvmw->pmd)) {
+			if (unlikely(is_migration_entry(pmd_to_swp_entry(*pvmw->pmd)))) {
+				swp_entry_t entry =3D pmd_to_swp_entry(*pvmw->pmd);
+
+				if (migration_entry_to_page(entry) !=3D page)
+					return not_found(pvmw);
+				return true;
+			}
+			return not_found(pvmw);
 		} else {
 			/* THP pmd was split under us: handle on pte level */
 			spin_unlock(pvmw->ptl);
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index c99d9512a45b..1175f6a24fdb 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -124,7 +124,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vm=
a, unsigned long address,
 {
 	pmd_t pmd;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
+	VM_BUG_ON((pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
+			   !pmd_devmap(*pmdp)) || !pmd_present(*pmdp));
 	pmd =3D pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
 	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
diff --git a/mm/rmap.c b/mm/rmap.c
index d6056310513f..6e1146a97021 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1304,6 +1304,7 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
 	bool ret =3D true;
 	enum ttu_flags flags =3D (enum ttu_flags)arg;
=20
+
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		return true;
@@ -1314,6 +1315,16 @@ static bool try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
 	}
=20
 	while (page_vma_mapped_walk(&pvmw)) {
+		/* PMD-mapped THP migration entry */
+		if (flags & TTU_MIGRATION) {
+			if (!pvmw.pte && page) {
+				VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page),
+						page);
+				set_pmd_migration_entry(&pvmw, page);
+				continue;
+			}
+		}
+
 		/*
 		 * If the page is mlock()d, we cannot swap it out.
 		 * If it's recently referenced (perhaps page_referenced
--=20
2.11.0



--=20
Best Regards,
Yan Zi


--1f57dV4W1liqtq4gtXitqmT7SpDASoOoG--

--keEUVb32kS2cUfX5SKEVHKMtbIat2U30b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlksLNwACgkQQYsvEZxO
pszUzQf/Suxb0x+kRXaJacDvHKzq3amxum0Kwc7ah+kJ+VwkwiCDFNPX86sJijrI
J85qaJ+7tSvgDOLGiSl+Q8WJTUU3s3DCOqEJ7TWTI9mrnAOexzos8Z7jxuZLerC7
t2SffDY24EqbZWLyk/KUuXXETM7y9PTCZ37kH9cLoQRcNH+uVnlsmQW86vwRhRz+
05PCoGXFAhLYkzw9KB+B7MurOwxoQ4ffZ763iMLskZa0/O6WFcFbsilF5ZO7gZpZ
pXnKBBZfBTSUd0MpIxSJMachGV5mBkapow6Fxm1Tfu40g+9xwu7h98BpwimGA0ZO
w4fH6AcO2L90x5iXke7AXSr04nJwMw==
=m2OZ
-----END PGP SIGNATURE-----

--keEUVb32kS2cUfX5SKEVHKMtbIat2U30b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
