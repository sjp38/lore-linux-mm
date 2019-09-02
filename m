Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C354C3A59B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:24:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC6BB215EA
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:24:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MlSSV7sP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC6BB215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1326E6B0006; Mon,  2 Sep 2019 05:24:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10A766B0007; Mon,  2 Sep 2019 05:24:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEAAD6B0008; Mon,  2 Sep 2019 05:24:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id C44A76B0006
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 05:24:11 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7B508906D
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:24:11 +0000 (UTC)
X-FDA: 75889444302.17.cry49_247e9e878fb2f
X-HE-Tag: cry49_247e9e878fb2f
X-Filterd-Recvd-Size: 23405
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:24:10 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x829NYqH102244;
	Mon, 2 Sep 2019 09:23:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2019-08-05;
 bh=2llDHjOZMyLJY+SY5DQDCY/bcXV1OQ0gvb0NF3UerdI=;
 b=MlSSV7sPSCb0DRHs07dfRcOLWvrqEbv/iKSqUbctc0/bZzKN0rWJNJ3ptIyw3r+LxA9C
 lerG/tSy/Qn5LyY85+rqhAhwh8fLEJUsx8Cr0v0D/tOicCdGfoF1R3rqVRQ9djepBeTq
 7bmxfNkVhgrOALTrcoq+0VleSd1muDf/4mqBEMNW+sXik42VWpeKIIMdrgLWYn76Ld3v
 mlPrQaxBs7inWvQ74Z+Djx8vqYNdPmsWXjv7jTlFzcZlGZdeCTG+cbIyqAjHqzZLivbD
 uIqzb8alRP49mg1Pp+yKvvnszsHs2EKL9oOI3hPnpzUCQF4AfCq9XFl2XomWgoY3OLVp sw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2us0b4010p-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 02 Sep 2019 09:23:56 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x829NEmb073631;
	Mon, 2 Sep 2019 09:23:55 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2uqgqk96av-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 02 Sep 2019 09:23:55 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x829NpiG029147;
	Mon, 2 Sep 2019 09:23:51 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 02 Sep 2019 02:23:50 -0700
From: William Kucharski <william.kucharski@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
        Song Liu <songliubraving@fb.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        William Kucharski <william.kucharski@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 2/2] mm,thp: Add experimental config option RO_EXEC_FILEMAP_HUGE_FAULT_THP
Date: Mon,  2 Sep 2019 03:23:41 -0600
Message-Id: <20190902092341.26712-3-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190902092341.26712-1-william.kucharski@oracle.com>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9367 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909020107
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9367 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909020107
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add filemap_huge_fault() to attempt to satisfy page
faults on memory-mapped read-only text pages using THP when possible.

Signed-off-by: William Kucharski <william.kucharski@oracle.com>
---
 include/linux/mm.h |   2 +
 mm/Kconfig         |  15 ++
 mm/filemap.c       | 398 +++++++++++++++++++++++++++++++++++++++++++--
 mm/huge_memory.c   |   3 +
 mm/mmap.c          |  39 ++++-
 mm/rmap.c          |   4 +-
 mm/vmscan.c        |   2 +-
 7 files changed, 446 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..2a5311721739 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2433,6 +2433,8 @@ extern void truncate_inode_pages_final(struct addre=
ss_space *);
=20
 /* generic vm_area_ops exported for stackable file systems */
 extern vm_fault_t filemap_fault(struct vm_fault *vmf);
+extern vm_fault_t filemap_huge_fault(struct vm_fault *vmf,
+			enum page_entry_size pe_size);
 extern void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff);
 extern vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf);
diff --git a/mm/Kconfig b/mm/Kconfig
index 56cec636a1fc..2debaded0e4d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -736,4 +736,19 @@ config ARCH_HAS_PTE_SPECIAL
 config ARCH_HAS_HUGEPD
 	bool
=20
+config RO_EXEC_FILEMAP_HUGE_FAULT_THP
+	bool "read-only exec filemap_huge_fault THP support (EXPERIMENTAL)"
+	depends on TRANSPARENT_HUGE_PAGECACHE && SHMEM
+
+	help
+	    Introduce filemap_huge_fault() to automatically map executable
+	    read-only pages of mapped files of suitable size and alignment
+	    using THP if possible.
+
+	    This is marked experimental because it is a new feature and is
+	    dependent upon filesystmes implementing readpages() in a way
+	    that will recognize large THP pages and read file content to
+	    them without polluting the pagecache with PAGESIZE pages due
+	    to readahead.
+
 endmenu
diff --git a/mm/filemap.c b/mm/filemap.c
index 38b46fc00855..5947d432a4e6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -199,13 +199,12 @@ static void unaccount_page_cache_page(struct addres=
s_space *mapping,
 	nr =3D hpage_nr_pages(page);
=20
 	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
-	if (PageSwapBacked(page)) {
+
+	if (PageSwapBacked(page))
 		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
-		if (PageTransHuge(page))
-			__dec_node_page_state(page, NR_SHMEM_THPS);
-	} else {
-		VM_BUG_ON_PAGE(PageTransHuge(page), page);
-	}
+
+	if (PageTransHuge(page))
+		__dec_node_page_state(page, NR_SHMEM_THPS);
=20
 	/*
 	 * At this point page must be either written or cleaned by
@@ -303,6 +302,9 @@ static void page_cache_delete_batch(struct address_sp=
ace *mapping,
 			break;
 		if (xa_is_value(page))
 			continue;
+
+VM_BUG_ON_PAGE(xa_is_internal(page), page);
+
 		if (!tail_pages) {
 			/*
 			 * Some page got inserted in our range? Skip it. We
@@ -315,6 +317,11 @@ static void page_cache_delete_batch(struct address_s=
pace *mapping,
 				continue;
 			}
 			WARN_ON_ONCE(!PageLocked(page));
+
+			/*
+			 * If a THP is in the page cache, set the succeeding
+			 * cache entries for the PMD-sized page to NULL.
+			 */
 			if (PageTransHuge(page) && !PageHuge(page))
 				tail_pages =3D HPAGE_PMD_NR - 1;
 			page->mapping =3D NULL;
@@ -324,8 +331,6 @@ static void page_cache_delete_batch(struct address_sp=
ace *mapping,
 			 */
 			i++;
 		} else {
-			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
-					!=3D pvec->pages[i]->index, page);
 			tail_pages--;
 		}
 		xas_store(&xas, NULL);
@@ -881,7 +886,10 @@ static int __add_to_page_cache_locked(struct page *p=
age,
 		mapping->nrpages++;
=20
 		/* hugetlb pages do not participate in page cache accounting */
-		if (!huge)
+		if (PageTransHuge(page) && !huge)
+			__mod_node_page_state(page_pgdat(page),
+				NR_FILE_PAGES, HPAGE_PMD_NR);
+		else
 			__inc_node_page_state(page, NR_FILE_PAGES);
 unlock:
 		xas_unlock_irq(&xas);
@@ -1663,7 +1671,8 @@ struct page *pagecache_get_page(struct address_spac=
e *mapping, pgoff_t offset,
 no_page:
 	if (!page && (fgp_flags & FGP_CREAT)) {
 		int err;
-		if ((fgp_flags & FGP_WRITE) && mapping_cap_account_dirty(mapping))
+		if ((fgp_flags & FGP_WRITE) &&
+			mapping_cap_account_dirty(mapping))
 			gfp_mask |=3D __GFP_WRITE;
 		if (fgp_flags & FGP_NOFS)
 			gfp_mask &=3D ~__GFP_FS;
@@ -2643,6 +2652,372 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 }
 EXPORT_SYMBOL(filemap_fault);
=20
+#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
+/*
+ * There is a change coming to store only the head page of a compound pa=
ge in
+ * the head cache.
+ *
+ * When that change is present in the kernel, remove this #define
+ */
+#define	PAGE_CACHE_STORE_COMPOUND_TAIL_PAGES
+
+/*
+ * Check for an entry in the page cache which would conflict with the ad=
dress
+ * range we wish to map using a THP or is otherwise unusable to map a la=
rge
+ * cached page.
+ *
+ * The routine will return true if a usable page is found in the page ca=
che
+ * (and *pagep will be set to the address of the cached page), or if no
+ * cached page is found (and *pagep will be set to NULL).
+ */
+static bool
+filemap_huge_check_pagecache_usable(struct xa_state *xas,
+	struct page **pagep, pgoff_t hindex, pgoff_t hindex_max)
+{
+	struct page *page;
+
+	while (1) {
+		xas_set(xas, hindex);
+		page =3D xas_find(xas, hindex_max);
+
+		if (xas_retry(xas, page))
+			continue;
+
+		/*
+		 * A found entry is unusable if:
+		 *	+ the entry is an Xarray value, not a pointer
+		 *	+ the entry is an internal Xarray node
+		 *	+ the entry is not a compound page
+		 *	+ the order of the compound page is < HPAGE_PMD_ORDER
+		 *	+ the page index is not what we expect it to be
+		 */
+		if (!page)
+			break;
+
+		if (xa_is_value(page) || xa_is_internal(page))
+			return false;
+
+#ifdef PAGE_CACHE_STORE_COMPOUND_TAIL_PAGES
+		if ((!PageCompound(page)) || (page !=3D compound_head(page)))
+#else
+		if (!PageCompound(page))
+#endif
+			return false;
+
+		if (compound_order(page) < HPAGE_PMD_ORDER)
+			return false;
+
+		if (page->index !=3D hindex)
+			return false;
+
+		break;
+	}
+
+	*pagep =3D page;
+	return true;
+}
+
+/**
+ * filemap_huge_fault - read in file data for page fault handling to THP
+ * @vmf:	struct vm_fault containing details of the fault
+ * @pe_size:	large page size to map, currently this must be PE_SIZE_PMD
+ *
+ * filemap_huge_fault() is invoked via the vma operations vector for a
+ * mapped memory region to read in file data to a transparent huge page =
during
+ * a page fault.
+ *
+ * If for any reason we can't allocate a THP, map it or add it to the pa=
ge
+ * cache, VM_FAULT_FALLBACK will be returned which will cause the fault
+ * handler to try mapping the page using a PAGESIZE page, usually via
+ * filemap_fault() if so speicifed in the vma operations vector.
+ *
+ * Returns either VM_FAULT_FALLBACK or the result of calling allcc_set_p=
te()
+ * to map the new THP.
+ *
+ * NOTE: This routine depends upon the file system's readpage routine as
+ *       specified in the address space operations vector to recognize w=
hen it
+ *	 is being passed a large page and to read the approprate amount of da=
ta
+ *	 in full and without polluting the page cache for the large page itse=
lf
+ *	 with PAGESIZE pages to perform a buffered read or to pollute what
+ *	 would be the page cache space for any succeeding pages with PAGESIZE
+ *	 pages due to readahead.
+ *
+ *	 It is VITAL that this routine not be enabled without such filesystem
+ *	 support. As there is no way to determine how many bytes were read by
+ *	 the readpage() operation, if only a PAGESIZE page is read, this rout=
ine
+ *	 will map the THP containing only the first PAGESIZE bytes of file da=
ta
+ *	 to satisfy the fault, which is never the result desired.
+ */
+vm_fault_t filemap_huge_fault(struct vm_fault *vmf,
+		enum page_entry_size pe_size)
+{
+	struct file *filp =3D vmf->vma->vm_file;
+	struct address_space *mapping =3D filp->f_mapping;
+	struct vm_area_struct *vma =3D vmf->vma;
+
+	unsigned long haddr =3D vmf->address & HPAGE_PMD_MASK;
+	pgoff_t hindex =3D round_down(vmf->pgoff, HPAGE_PMD_NR);
+	pgoff_t hindex_max =3D hindex + HPAGE_PMD_NR - 1;
+
+	struct page *cached_page, *hugepage;
+	struct page *new_page =3D NULL;
+
+	vm_fault_t ret =3D VM_FAULT_FALLBACK;
+	unsigned long nr;
+
+	int error;
+	bool retry_lookup =3D true;
+
+	XA_STATE_ORDER(xas, &mapping->i_pages, hindex, HPAGE_PMD_ORDER);
+
+	/*
+	 * Return VM_FAULT_FALLBACK if:
+	 *
+	 *	+ pe_size !=3D PE_SIZE_PMD
+	 *	+ FAULT_FLAG_WRITE is set in vmf->flags
+	 *	+ vma isn't aligned to allow a PMD mapping
+	 *	+ PMD would extend beyond the end of the vma
+	 */
+	if (pe_size !=3D PE_SIZE_PMD || (vmf->flags & FAULT_FLAG_WRITE) ||
+	    (haddr < vma->vm_start ||
+	    ((haddr + HPAGE_PMD_SIZE) > vma->vm_end)))
+		return ret;
+
+retry_lookup:
+	rcu_read_lock();
+
+	if (!filemap_huge_check_pagecache_usable(&xas, &cached_page, hindex,
+	    hindex_max)) {
+		/* found a conflicting entry in the page cache, so fallback */
+		rcu_read_unlock();
+		return ret;
+	} else if (cached_page) {
+		/* found a valid cached page, so map it */
+		rcu_read_unlock();
+		lock_page(cached_page);
+
+		/* was the cached page truncated while waiting for the lock? */
+		if (unlikely(cached_page->mapping !=3D mapping)) {
+			unlock_page(cached_page);
+
+			/* retry once */
+			if (retry_lookup) {
+				retry_lookup =3D false;
+				goto retry_lookup;
+			}
+
+			return ret;
+		}
+
+		if (unlikely(!PageUptodate(cached_page))) {
+			unlock_page(cached_page);
+			return ret;
+		}
+
+		VM_BUG_ON_PAGE(cached_page->index !=3D hindex, cached_page);
+
+		hugepage =3D cached_page;
+		goto map_huge;
+	}
+
+	rcu_read_unlock();
+
+	/* allocate huge THP page in VMA */
+	new_page =3D __page_cache_alloc(vmf->gfp_mask | __GFP_COMP |
+		__GFP_NOWARN | __GFP_NORETRY, HPAGE_PMD_ORDER);
+
+	if (unlikely(!new_page))
+		return ret;
+
+	do {
+		xas_lock_irq(&xas);
+		xas_set(&xas, hindex);
+		xas_create_range(&xas);
+
+		if (!(xas_error(&xas)))
+			break;
+
+		xas_unlock_irq(&xas);
+
+		if (!xas_nomem(&xas, GFP_KERNEL)) {
+			/* error creating range, so free THP and fallback */
+			if (new_page)
+				put_page(new_page);
+
+			return ret;
+		}
+	} while (1);
+
+	/* i_pages is locked here */
+
+	/*
+	 * Double check that an entry did not sneak into the page cache while
+	 * creating Xarray entries for the new page.
+	 */
+	if (!filemap_huge_check_pagecache_usable(&xas, &cached_page, hindex,
+	    hindex_max)) {
+		/*
+		 * An unusable entry was found, so delete the newly allocated
+		 * page and fallback.
+		 */
+		put_page(new_page);
+		xas_unlock_irq(&xas);
+		return ret;
+	} else if (cached_page) {
+		/*
+		 * A valid large page was found in the page cache, so free the
+		 * newly allocated page and map the cached page instead.
+		 */
+		put_page(new_page);
+		new_page =3D NULL;
+		xas_unlock_irq(&xas);
+
+		lock_page(cached_page);
+
+		/* was the cached page truncated while waiting for the lock? */
+		if (unlikely(cached_page->mapping !=3D mapping)) {
+			unlock_page(cached_page);
+
+			/* retry once */
+			if (retry_lookup) {
+				retry_lookup =3D false;
+				goto retry_lookup;
+			}
+
+			return ret;
+		}
+
+		if (unlikely(!PageUptodate(cached_page))) {
+			unlock_page(cached_page);
+			return ret;
+		}
+
+		VM_BUG_ON_PAGE(cached_page->index !=3D hindex, cached_page);
+
+		hugepage =3D cached_page;
+		goto map_huge;
+	}
+
+	prep_transhuge_page(new_page);
+	new_page->mapping =3D mapping;
+	new_page->index =3D hindex;
+	__SetPageLocked(new_page);
+
+	count_vm_event(THP_FILE_ALLOC);
+	xas_set(&xas, hindex);
+
+	for (nr =3D 0; nr < HPAGE_PMD_NR; nr++) {
+#ifdef PAGE_CACHE_STORE_COMPOUND_TAIL_PAGES
+		/*
+		 * Store pointers to both head and tail pages of a compound
+		 * page in the page cache.
+		 */
+		xas_store(&xas, new_page + nr);
+#else
+		/*
+		 * All entries for a compound page in the page cache should
+		 * point to the head page.
+		 */
+		xas_store(&xas, new_page);
+#endif
+		xas_next(&xas);
+	}
+
+	mapping->nrpages +=3D HPAGE_PMD_NR;
+	xas_unlock_irq(&xas);
+
+	/*
+	 * The readpage() operation below is expected to fill the large
+	 * page with data without polluting the page cache with
+	 * PAGESIZE entries due to a buffered read and/or readahead().
+	 *
+	 * A filesystem's vm_operations_struct huge_fault field should
+	 * never point to this routine without such a capability, and
+	 * without it a call to this routine would eventually just
+	 * fall through to the normal fault op anyway.
+	 */
+	error =3D mapping->a_ops->readpage(vmf->vma->vm_file, new_page);
+
+	if (unlikely(error)) {
+		ret =3D VM_FAULT_SIGBUS;
+		goto delete_hugepage_from_page_cache;
+	}
+
+	if (wait_on_page_locked_killable(new_page)) {
+		ret =3D VM_FAULT_SIGSEGV;
+		goto delete_hugepage_from_page_cache;
+	}
+
+	if (!PageUptodate(new_page)) {
+		/* EIO */
+		ret =3D VM_FAULT_SIGBUS;
+		goto delete_hugepage_from_page_cache;
+	}
+
+	lock_page(new_page);
+
+	/* did the page get truncated while waiting for the lock? */
+	if (unlikely(new_page->mapping !=3D mapping)) {
+		unlock_page(new_page);
+		goto delete_hugepage_from_page_cache;
+	}
+
+	__inc_node_page_state(new_page, NR_SHMEM_THPS);
+	__mod_node_page_state(page_pgdat(new_page),
+		NR_FILE_PAGES, HPAGE_PMD_NR);
+	__mod_node_page_state(page_pgdat(new_page),
+		NR_SHMEM, HPAGE_PMD_NR);
+
+	hugepage =3D new_page;
+
+map_huge:
+	/* map hugepage at the PMD level */
+
+	ret =3D alloc_set_pte(vmf, vmf->memcg, hugepage);
+
+	VM_BUG_ON_PAGE((!(pmd_trans_huge(*vmf->pmd))), hugepage);
+	VM_BUG_ON_PAGE(!(PageTransHuge(hugepage)), hugepage);
+
+	if (likely(!(ret & VM_FAULT_ERROR))) {
+		vmf->address =3D haddr;
+		vmf->page =3D hugepage;
+
+		page_ref_add(hugepage, HPAGE_PMD_NR);
+		count_vm_event(THP_FILE_MAPPED);
+	} else {
+		if (new_page) {
+			__mod_node_page_state(page_pgdat(new_page),
+				NR_FILE_PAGES, -HPAGE_PMD_NR);
+			__mod_node_page_state(page_pgdat(new_page),
+				NR_SHMEM, -HPAGE_PMD_NR);
+			__dec_node_page_state(new_page, NR_SHMEM_THPS);
+
+delete_hugepage_from_page_cache:
+			xas_lock_irq(&xas);
+			xas_set(&xas, hindex);
+
+			for (nr =3D 0; nr < HPAGE_PMD_NR; nr++) {
+				xas_store(&xas, NULL);
+				xas_next(&xas);
+			}
+
+			new_page->mapping =3D NULL;
+			xas_unlock_irq(&xas);
+
+			mapping->nrpages -=3D HPAGE_PMD_NR;
+			unlock_page(new_page);
+			page_ref_dec(new_page);	/* decrement page coche ref */
+			put_page(new_page);	/* done with page */
+			return ret;
+		}
+	}
+
+	unlock_page(hugepage);
+	return ret;
+}
+EXPORT_SYMBOL(filemap_huge_fault);
+#endif
+
 void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff)
 {
@@ -2925,7 +3300,8 @@ struct page *read_cache_page(struct address_space *=
mapping,
 EXPORT_SYMBOL(read_cache_page);
=20
 /**
- * read_cache_page_gfp - read into page cache, using specified page allo=
cation flags.
+ * read_cache_page_gfp - read into page cache, using specified page allo=
cation
+ *			 flags.
  * @mapping:	the page's address_space
  * @index:	the page index
  * @gfp:	the page allocator flags to use if allocating
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de1f15969e27..ea3dbb6fa538 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -544,8 +544,11 @@ unsigned long thp_get_unmapped_area(struct file *fil=
p, unsigned long addr,
=20
 	if (addr)
 		goto out;
+
+#ifndef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
 	if (!IS_DAX(filp->f_mapping->host) || !IS_ENABLED(CONFIG_FS_DAX_PMD))
 		goto out;
+#endif
=20
 	addr =3D __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
 	if (addr)
diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..d8b3bce71075 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1391,6 +1391,8 @@ unsigned long do_mmap(struct file *file, unsigned l=
ong addr,
 	struct mm_struct *mm =3D current->mm;
 	int pkey =3D 0;
=20
+	unsigned long vm_maywrite =3D VM_MAYWRITE;
+
 	*populate =3D 0;
=20
 	if (!len)
@@ -1426,10 +1428,41 @@ unsigned long do_mmap(struct file *file, unsigned=
 long addr,
 	if (mm->map_count > sysctl_max_map_count)
 		return -ENOMEM;
=20
-	/* Obtain the address to map to. we verify (or select) it and ensure
+	/*
+	 * Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
-	addr =3D get_unmapped_area(file, addr, len, pgoff, flags);
+
+#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
+	/*
+	 * If THP is enabled, it's a read-only executable that is
+	 * MAP_PRIVATE mapped, the length is larger than a PMD page
+	 * and either it's not a MAP_FIXED mapping or the passed address is
+	 * properly aligned for a PMD page, attempt to get an appropriate
+	 * address at which to map a PMD-sized THP page, otherwise call the
+	 * normal routine.
+	 */
+	if ((prot & PROT_READ) && (prot & PROT_EXEC) &&
+		(!(prot & PROT_WRITE)) && (flags & MAP_PRIVATE) &&
+		(!(flags & MAP_FIXED)) && len >=3D HPAGE_PMD_SIZE) {
+		addr =3D thp_get_unmapped_area(file, addr, len, pgoff, flags);
+
+		if (addr && (!(addr & ~HPAGE_PMD_MASK))) {
+			/*
+			 * If we got a suitable THP mapping address, shut off
+			 * VM_MAYWRITE for the region, since it's never what
+			 * we would want.
+			 */
+			vm_maywrite =3D 0;
+		} else
+			addr =3D get_unmapped_area(file, addr, len, pgoff, flags);
+	} else {
+#endif
+		addr =3D get_unmapped_area(file, addr, len, pgoff, flags);
+#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
+	}
+#endif
+
 	if (offset_in_page(addr))
 		return addr;
=20
@@ -1451,7 +1484,7 @@ unsigned long do_mmap(struct file *file, unsigned l=
ong addr,
 	 * of the memory object, so we don't do any here.
 	 */
 	vm_flags |=3D calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) =
|
-			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
+			mm->def_flags | VM_MAYREAD | vm_maywrite | VM_MAYEXEC;
=20
 	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
diff --git a/mm/rmap.c b/mm/rmap.c
index 003377e24232..aacc6e330329 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1192,7 +1192,7 @@ void page_add_file_rmap(struct page *page, bool com=
pound)
 		}
 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
 			goto out;
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+
 		__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (PageTransCompound(page) && page_mapping(page)) {
@@ -1232,7 +1232,7 @@ static void page_remove_file_rmap(struct page *page=
, bool compound)
 		}
 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 			goto out;
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+
 		__dec_node_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (!atomic_add_negative(-1, &page->_mapcount))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6c5d0b28321..47a19c59c9a2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -930,7 +930,7 @@ static int __remove_mapping(struct address_space *map=
ping, struct page *page,
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under the i_pages lock, then this ordering is not required.
 	 */
-	if (unlikely(PageTransHuge(page)) && PageSwapCache(page))
+	if (unlikely(PageTransHuge(page)))
 		refcount =3D 1 + HPAGE_PMD_NR;
 	else
 		refcount =3D 2;
--=20
2.21.0


