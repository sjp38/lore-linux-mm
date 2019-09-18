Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D27A6C4CECE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FC23218AF
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="Aru0W2Yg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FC23218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AC806B02A1; Wed, 18 Sep 2019 08:59:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 512DE6B02A3; Wed, 18 Sep 2019 08:59:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38C0D6B02A5; Wed, 18 Sep 2019 08:59:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 155C26B02A2
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 08:59:33 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 90CDC824376D
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:32 +0000 (UTC)
X-FDA: 75948047784.04.smash26_532a38d249a36
X-HE-Tag: smash26_532a38d249a36
X-Filterd-Recvd-Size: 13459
Received: from ste-pvt-msa1.bahnhof.se (ste-pvt-msa1.bahnhof.se [213.80.101.70])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTP id 30CD23F6DC;
	Wed, 18 Sep 2019 14:59:30 +0200 (CEST)
Authentication-Results: ste-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=Aru0W2Yg;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from ste-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (ste-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xiRUd--qyrav; Wed, 18 Sep 2019 14:59:28 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id 4F6C33F247;
	Wed, 18 Sep 2019 14:59:24 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 6407E360326;
	Wed, 18 Sep 2019 14:59:24 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568811564; bh=uMSGH2llUf0g/5IIoIoj2eeW+M0du8bxg9TfkDKQh5Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Aru0W2Ygo/WXRRZlOXyYkAMlfPAOVVMc5lsIlkOv3UNx/D+Dek3O8RNELJxDKOa7q
	 Ox4U2io+QoTysr3p3CYhqcsHuXCJK55HFiA7wCySzYpLvxFwUMGnayrPwYv+whlR4y
	 +QDD3Cx+btbMqTy5FIa7yooKowVp9D9+rbshP3Z8=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thomas_os@shipmail.org>
To: linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org
Cc: pv-drivers@vmware.com,
	linux-graphics-maintainer@vmware.com,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 3/7] drm/ttm: Convert vm callbacks to helpers
Date: Wed, 18 Sep 2019 14:59:10 +0200
Message-Id: <20190918125914.38497-4-thomas_os@shipmail.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190918125914.38497-1-thomas_os@shipmail.org>
References: <20190918125914.38497-1-thomas_os@shipmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

With the vmwgfx dirty tracking, the default TTM fault handler is not
completely sufficient (vmwgfx need to modify the vma->vm_flags member,
and also needs to restrict the number of prefaults).

We also want to replicate the new ttm_bo_vm_reserve() functionality

So start turning the TTM vm code into helpers: ttm_bo_vm_fault_reserved()
and ttm_bo_vm_reserve(), and provide a default TTM fault handler for othe=
r
drivers to use.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
---
 drivers/gpu/drm/ttm/ttm_bo_vm.c | 168 ++++++++++++++++++++------------
 include/drm/ttm/ttm_bo_api.h    |  14 +++
 2 files changed, 119 insertions(+), 63 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo=
_vm.c
index 8963546bf245..0ac11837533f 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -42,8 +42,6 @@
 #include <linux/uaccess.h>
 #include <linux/mem_encrypt.h>
=20
-#define TTM_BO_VM_NUM_PREFAULT 16
-
 static vm_fault_t ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 				struct vm_fault *vmf)
 {
@@ -106,24 +104,30 @@ static unsigned long ttm_bo_io_mem_pfn(struct ttm_b=
uffer_object *bo,
 		+ page_offset;
 }
=20
-static vm_fault_t ttm_bo_vm_fault(struct vm_fault *vmf)
+/**
+ * ttm_bo_vm_reserve - Reserve a buffer object in a retryable vm callbac=
k
+ * @bo: The buffer object
+ * @vmf: The fault structure handed to the callback
+ *
+ * vm callbacks like fault() and *_mkwrite() allow for the mm_sem to be =
dropped
+ * during long waits, and after the wait the callback will be restarted.=
 This
+ * is to allow other threads using the same virtual memory space concurr=
ent
+ * access to map(), unmap() completely unrelated buffer objects. TTM buf=
fer
+ * object reservations sometimes wait for GPU and should therefore be
+ * considered long waits. This function reserves the buffer object inter=
ruptibly
+ * taking this into account. Starvation is avoided by the vm system not
+ * allowing too many repeated restarts.
+ * This function is intended to be used in customized fault() and _mkwri=
te()
+ * handlers.
+ *
+ * Return:
+ *    0 on success and the bo was reserved.
+ *    VM_FAULT_RETRY if blocking wait.
+ *    VM_FAULT_NOPAGE if blocking wait and retrying was not allowed.
+ */
+vm_fault_t ttm_bo_vm_reserve(struct ttm_buffer_object *bo,
+			     struct vm_fault *vmf)
 {
-	struct vm_area_struct *vma =3D vmf->vma;
-	struct ttm_buffer_object *bo =3D vma->vm_private_data;
-	struct ttm_bo_device *bdev =3D bo->bdev;
-	unsigned long page_offset;
-	unsigned long page_last;
-	unsigned long pfn;
-	struct ttm_tt *ttm =3D NULL;
-	struct page *page;
-	int err;
-	int i;
-	vm_fault_t ret =3D VM_FAULT_NOPAGE;
-	unsigned long address =3D vmf->address;
-	struct ttm_mem_type_manager *man =3D
-		&bdev->man[bo->mem.mem_type];
-	struct vm_area_struct cvma;
-
 	/*
 	 * Work around locking order reversal in fault / nopfn
 	 * between mmap_sem and bo_reserve: Perform a trylock operation
@@ -150,14 +154,54 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *=
vmf)
 		return VM_FAULT_NOPAGE;
 	}
=20
+	return 0;
+}
+EXPORT_SYMBOL(ttm_bo_vm_reserve);
+
+/**
+ * ttm_bo_vm_fault_reserved - TTM fault helper
+ * @vmf: The struct vm_fault given as argument to the fault callback
+ * @prot: The page protection to be used for this memory area.
+ * @num_prefault: Maximum number of prefault pages. The caller may want =
to
+ * specify this based on madvice settings and the size of the GPU object
+ * backed by the memory.
+ *
+ * This function inserts one or more page table entries pointing to the
+ * memory backing the buffer object, and then returns a return code
+ * instructing the caller to retry the page access.
+ *
+ * Return:
+ *   VM_FAULT_NOPAGE on success or pending signal
+ *   VM_FAULT_SIGBUS on unspecified error
+ *   VM_FAULT_OOM on out-of-memory
+ *   VM_FAULT_RETRY if retryable wait
+ */
+vm_fault_t ttm_bo_vm_fault_reserved(struct vm_fault *vmf,
+				    pgprot_t prot,
+				    pgoff_t num_prefault)
+{
+	struct vm_area_struct *vma =3D vmf->vma;
+	struct vm_area_struct cvma =3D *vma;
+	struct ttm_buffer_object *bo =3D vma->vm_private_data;
+	struct ttm_bo_device *bdev =3D bo->bdev;
+	unsigned long page_offset;
+	unsigned long page_last;
+	unsigned long pfn;
+	struct ttm_tt *ttm =3D NULL;
+	struct page *page;
+	int err;
+	pgoff_t i;
+	vm_fault_t ret =3D VM_FAULT_NOPAGE;
+	unsigned long address =3D vmf->address;
+	struct ttm_mem_type_manager *man =3D
+		&bdev->man[bo->mem.mem_type];
+
 	/*
 	 * Refuse to fault imported pages. This should be handled
 	 * (if at all) by redirecting mmap to the exporter.
 	 */
-	if (bo->ttm && (bo->ttm->page_flags & TTM_PAGE_FLAG_SG)) {
-		ret =3D VM_FAULT_SIGBUS;
-		goto out_unlock;
-	}
+	if (bo->ttm && (bo->ttm->page_flags & TTM_PAGE_FLAG_SG))
+		return VM_FAULT_SIGBUS;
=20
 	if (bdev->driver->fault_reserve_notify) {
 		struct dma_fence *moving =3D dma_fence_get(bo->moving);
@@ -168,11 +212,9 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *v=
mf)
 			break;
 		case -EBUSY:
 		case -ERESTARTSYS:
-			ret =3D VM_FAULT_NOPAGE;
-			goto out_unlock;
+			return VM_FAULT_NOPAGE;
 		default:
-			ret =3D VM_FAULT_SIGBUS;
-			goto out_unlock;
+			return VM_FAULT_SIGBUS;
 		}
=20
 		if (bo->moving !=3D moving) {
@@ -188,21 +230,12 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *=
vmf)
 	 * move.
 	 */
 	ret =3D ttm_bo_vm_fault_idle(bo, vmf);
-	if (unlikely(ret !=3D 0)) {
-		if (ret =3D=3D VM_FAULT_RETRY &&
-		    !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
-			/* The BO has already been unreserved. */
-			return ret;
-		}
-
-		goto out_unlock;
-	}
+	if (unlikely(ret !=3D 0))
+		return ret;
=20
 	err =3D ttm_mem_io_lock(man, true);
-	if (unlikely(err !=3D 0)) {
-		ret =3D VM_FAULT_NOPAGE;
-		goto out_unlock;
-	}
+	if (unlikely(err !=3D 0))
+		return VM_FAULT_NOPAGE;
 	err =3D ttm_mem_io_reserve_vm(bo);
 	if (unlikely(err !=3D 0)) {
 		ret =3D VM_FAULT_SIGBUS;
@@ -219,18 +252,8 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *v=
mf)
 		goto out_io_unlock;
 	}
=20
-	/*
-	 * Make a local vma copy to modify the page_prot member
-	 * and vm_flags if necessary. The vma parameter is protected
-	 * by mmap_sem in write mode.
-	 */
-	cvma =3D *vma;
-	cvma.vm_page_prot =3D vm_get_page_prot(cvma.vm_flags);
-
-	if (bo->mem.bus.is_iomem) {
-		cvma.vm_page_prot =3D ttm_io_prot(bo->mem.placement,
-						cvma.vm_page_prot);
-	} else {
+	cvma.vm_page_prot =3D ttm_io_prot(bo->mem.placement, prot);
+	if (!bo->mem.bus.is_iomem) {
 		struct ttm_operation_ctx ctx =3D {
 			.interruptible =3D false,
 			.no_wait_gpu =3D false,
@@ -239,24 +262,21 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *=
vmf)
 		};
=20
 		ttm =3D bo->ttm;
-		cvma.vm_page_prot =3D ttm_io_prot(bo->mem.placement,
-						cvma.vm_page_prot);
-
-		/* Allocate all page at once, most common usage */
-		if (ttm_tt_populate(ttm, &ctx)) {
+		if (ttm_tt_populate(bo->ttm, &ctx)) {
 			ret =3D VM_FAULT_OOM;
 			goto out_io_unlock;
 		}
+	} else {
+		/* Iomem should not be marked encrypted */
+		cvma.vm_page_prot =3D pgprot_decrypted(cvma.vm_page_prot);
 	}
=20
 	/*
 	 * Speculatively prefault a number of pages. Only error on
 	 * first page.
 	 */
-	for (i =3D 0; i < TTM_BO_VM_NUM_PREFAULT; ++i) {
+	for (i =3D 0; i < num_prefault; ++i) {
 		if (bo->mem.bus.is_iomem) {
-			/* Iomem should not be marked encrypted */
-			cvma.vm_page_prot =3D pgprot_decrypted(cvma.vm_page_prot);
 			pfn =3D ttm_bo_io_mem_pfn(bo, page_offset);
 		} else {
 			page =3D ttm->pages[page_offset];
@@ -294,12 +314,32 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *=
vmf)
 	ret =3D VM_FAULT_NOPAGE;
 out_io_unlock:
 	ttm_mem_io_unlock(man);
-out_unlock:
+	return ret;
+}
+EXPORT_SYMBOL(ttm_bo_vm_fault_reserved);
+
+static vm_fault_t ttm_bo_vm_fault(struct vm_fault *vmf)
+{
+	struct vm_area_struct *vma =3D vmf->vma;
+	pgprot_t prot;
+	struct ttm_buffer_object *bo =3D vma->vm_private_data;
+	vm_fault_t ret;
+
+	ret =3D ttm_bo_vm_reserve(bo, vmf);
+	if (ret)
+		return ret;
+
+	prot =3D vm_get_page_prot(vma->vm_flags);
+	ret =3D ttm_bo_vm_fault_reserved(vmf, prot, TTM_BO_VM_NUM_PREFAULT);
+	if (ret =3D=3D VM_FAULT_RETRY && !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT=
))
+		return ret;
+
 	dma_resv_unlock(bo->base.resv);
+
 	return ret;
 }
=20
-static void ttm_bo_vm_open(struct vm_area_struct *vma)
+void ttm_bo_vm_open(struct vm_area_struct *vma)
 {
 	struct ttm_buffer_object *bo =3D vma->vm_private_data;
=20
@@ -307,14 +347,16 @@ static void ttm_bo_vm_open(struct vm_area_struct *v=
ma)
=20
 	ttm_bo_get(bo);
 }
+EXPORT_SYMBOL(ttm_bo_vm_open);
=20
-static void ttm_bo_vm_close(struct vm_area_struct *vma)
+void ttm_bo_vm_close(struct vm_area_struct *vma)
 {
 	struct ttm_buffer_object *bo =3D vma->vm_private_data;
=20
 	ttm_bo_put(bo);
 	vma->vm_private_data =3D NULL;
 }
+EXPORT_SYMBOL(ttm_bo_vm_close);
=20
 static int ttm_bo_vm_access_kmap(struct ttm_buffer_object *bo,
 				 unsigned long offset,
diff --git a/include/drm/ttm/ttm_bo_api.h b/include/drm/ttm/ttm_bo_api.h
index 43c4929a2171..851260cbbb2f 100644
--- a/include/drm/ttm/ttm_bo_api.h
+++ b/include/drm/ttm/ttm_bo_api.h
@@ -785,4 +785,18 @@ static inline bool ttm_bo_uses_embedded_gem_object(s=
truct ttm_buffer_object *bo)
 {
 	return bo->base.dev !=3D NULL;
 }
+
+/* Default number of pre-faulted pages in the TTM fault handler */
+#define TTM_BO_VM_NUM_PREFAULT 16
+
+vm_fault_t ttm_bo_vm_reserve(struct ttm_buffer_object *bo,
+			     struct vm_fault *vmf);
+
+vm_fault_t ttm_bo_vm_fault_reserved(struct vm_fault *vmf,
+				    pgprot_t prot,
+				    pgoff_t num_prefault);
+
+void ttm_bo_vm_open(struct vm_area_struct *vma);
+
+void ttm_bo_vm_close(struct vm_area_struct *vma);
 #endif
--=20
2.20.1


