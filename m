Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B4F5C4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:32:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 171FB20644
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:32:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="DtSV3VOi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 171FB20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DBA86B000E; Fri, 13 Sep 2019 05:32:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93A406B0010; Fri, 13 Sep 2019 05:32:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8019B6B0266; Fri, 13 Sep 2019 05:32:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0037.hostedemail.com [216.40.44.37])
	by kanga.kvack.org (Postfix) with ESMTP id 599206B000E
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:32:48 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EB199256FF
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:32:47 +0000 (UTC)
X-FDA: 75929382774.27.jar58_185217d553a2a
X-HE-Tag: jar58_185217d553a2a
X-Filterd-Recvd-Size: 12461
Received: from pio-pvt-msa3.bahnhof.se (pio-pvt-msa3.bahnhof.se [79.136.2.42])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:32:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTP id A11A03F503;
	Fri, 13 Sep 2019 11:32:30 +0200 (CEST)
Authentication-Results: pio-pvt-msa3.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=DtSV3VOi;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa3.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa3.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bGTtFi6o9eYD; Fri, 13 Sep 2019 11:32:29 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTPA id 58C8B3F4EE;
	Fri, 13 Sep 2019 11:32:29 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 29A90360311;
	Fri, 13 Sep 2019 11:32:28 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568367148; bh=hZW2n+AdOtbaVvfL20mazvk3WmrfNWXDYeDIDYMBCkQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=DtSV3VOi16jvljyIXdN1Zk2F3MASHXGH9R1TP1otzuQhwYc5mUkjevgOEt2TfH0rU
	 7/8Kaa0ScxiRC0NUSHVBAycNpQ4QcPNtuxka/PPUh8Tc8HFLfMlDSc1EZtxAmQlIeZ
	 CKV1dIB8/lrbmaDdv4S+kDAkkh7Wwm2u/Oq/Taq0=
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
	Christoph Hellwig <hch@infradead.org>,
	Deepak Rawat <drawat@vmware.com>
Subject: [RFC PATCH 5/7] drm/vmwgfx: Use an RBtree instead of linked list for MOB resources
Date: Fri, 13 Sep 2019 11:32:11 +0200
Message-Id: <20190913093213.27254-6-thomas_os@shipmail.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190913093213.27254-1-thomas_os@shipmail.org>
References: <20190913093213.27254-1-thomas_os@shipmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

With emulated coherent memory we need to be able to quickly look up
a resource from the MOB offset. Instead of traversing a linked list with
O(n) worst case, use an RBtree with O(log n) worst case complexity.

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
Reviewed-by: Deepak Rawat <drawat@vmware.com>
---
 drivers/gpu/drm/vmwgfx/vmwgfx_bo.c         |  5 ++--
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h        | 10 +++----
 drivers/gpu/drm/vmwgfx/vmwgfx_page_dirty.c | 12 ++++----
 drivers/gpu/drm/vmwgfx/vmwgfx_resource.c   | 33 ++++++++++++++++------
 4 files changed, 38 insertions(+), 22 deletions(-)

diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_bo.c b/drivers/gpu/drm/vmwgfx/=
vmwgfx_bo.c
index 869aeaec2f86..18e4b329e563 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_bo.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_bo.c
@@ -463,6 +463,7 @@ void vmw_bo_bo_free(struct ttm_buffer_object *bo)
 	struct vmw_buffer_object *vmw_bo =3D vmw_buffer_object(bo);
=20
 	WARN_ON(vmw_bo->dirty);
+	WARN_ON(!RB_EMPTY_ROOT(&vmw_bo->res_tree));
 	vmw_bo_unmap(vmw_bo);
 	kfree(vmw_bo);
 }
@@ -479,6 +480,7 @@ static void vmw_user_bo_destroy(struct ttm_buffer_obj=
ect *bo)
 	struct vmw_buffer_object *vbo =3D &vmw_user_bo->vbo;
=20
 	WARN_ON(vbo->dirty);
+	WARN_ON(!RB_EMPTY_ROOT(&vbo->res_tree));
 	vmw_bo_unmap(vbo);
 	ttm_prime_object_kfree(vmw_user_bo, prime);
 }
@@ -514,8 +516,7 @@ int vmw_bo_init(struct vmw_private *dev_priv,
 	memset(vmw_bo, 0, sizeof(*vmw_bo));
 	BUILD_BUG_ON(TTM_MAX_BO_PRIORITY <=3D 3);
 	vmw_bo->base.priority =3D 3;
-
-	INIT_LIST_HEAD(&vmw_bo->res_list);
+	vmw_bo->res_tree =3D RB_ROOT;
=20
 	ret =3D ttm_bo_init(bdev, &vmw_bo->base, size,
 			  ttm_bo_type_device, placement,
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h b/drivers/gpu/drm/vmwgfx=
/vmwgfx_drv.h
index 4d1f80811ac0..f8cb9ed90862 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
@@ -100,7 +100,7 @@ struct vmw_fpriv {
 /**
  * struct vmw_buffer_object - TTM buffer object with vmwgfx additions
  * @base: The TTM buffer object
- * @res_list: List of resources using this buffer object as a backing MO=
B
+ * @res_tree: RB tree of resources using this buffer object as a backing=
 MOB
  * @pin_count: pin depth
  * @dx_query_ctx: DX context if this buffer object is used as a DX query=
 MOB
  * @map: Kmap object for semi-persistent mappings
@@ -109,7 +109,7 @@ struct vmw_fpriv {
  */
 struct vmw_buffer_object {
 	struct ttm_buffer_object base;
-	struct list_head res_list;
+	struct rb_root res_tree;
 	s32 pin_count;
 	/* Not ref-counted.  Protected by binding_mutex */
 	struct vmw_resource *dx_query_ctx;
@@ -157,8 +157,8 @@ struct vmw_res_func;
  * pin-count greater than zero. It is not on the resource LRU lists and =
its
  * backup buffer is pinned. Hence it can't be evicted.
  * @func: Method vtable for this resource. Immutable.
+ * @mob_node; Node for the MOB backup rbtree. Protected by @backup reser=
ved.
  * @lru_head: List head for the LRU list. Protected by @dev_priv::resour=
ce_lock.
- * @mob_head: List head for the MOB backup list. Protected by @backup re=
served.
  * @binding_head: List head for the context binding list. Protected by
  * the @dev_priv::binding_mutex
  * @res_free: The resource destructor.
@@ -179,8 +179,8 @@ struct vmw_resource {
 	unsigned long backup_offset;
 	unsigned long pin_count;
 	const struct vmw_res_func *func;
+	struct rb_node mob_node;
 	struct list_head lru_head;
-	struct list_head mob_head;
 	struct list_head binding_head;
 	struct vmw_resource_dirty *dirty;
 	void (*res_free) (struct vmw_resource *res);
@@ -736,7 +736,7 @@ void vmw_resource_dirty_update(struct vmw_resource *r=
es, pgoff_t start,
  */
 static inline bool vmw_resource_mob_attached(const struct vmw_resource *=
res)
 {
-	return !list_empty(&res->mob_head);
+	return !RB_EMPTY_NODE(&res->mob_node);
 }
=20
 /**
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_page_dirty.c b/drivers/gpu/drm=
/vmwgfx/vmwgfx_page_dirty.c
index 11404862eff7..be3302a8e309 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_page_dirty.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_page_dirty.c
@@ -83,7 +83,7 @@ struct vmw_bo_dirty {
 static void vmw_bo_dirty_scan_pagetable(struct vmw_buffer_object *vbo)
 {
 	struct vmw_bo_dirty *dirty =3D vbo->dirty;
-	pgoff_t offset =3D drm_vma_node_start(&vbo->base.vma_node);
+	pgoff_t offset =3D drm_vma_node_start(&vbo->base.base.vma_node);
 	struct address_space *mapping =3D vbo->base.bdev->dev_mapping;
 	pgoff_t num_marked;
=20
@@ -120,7 +120,7 @@ static void vmw_bo_dirty_scan_pagetable(struct vmw_bu=
ffer_object *vbo)
 static void vmw_bo_dirty_scan_mkwrite(struct vmw_buffer_object *vbo)
 {
 	struct vmw_bo_dirty *dirty =3D vbo->dirty;
-	unsigned long offset =3D drm_vma_node_start(&vbo->base.vma_node);
+	unsigned long offset =3D drm_vma_node_start(&vbo->base.base.vma_node);
 	struct address_space *mapping =3D vbo->base.bdev->dev_mapping;
 	pgoff_t num_marked;
=20
@@ -220,7 +220,7 @@ int vmw_bo_dirty_add(struct vmw_buffer_object *vbo)
 		dirty->method =3D VMW_BO_DIRTY_PAGETABLE;
 	} else {
 		struct address_space *mapping =3D vbo->base.bdev->dev_mapping;
-		pgoff_t offset =3D drm_vma_node_start(&vbo->base.vma_node);
+		pgoff_t offset =3D drm_vma_node_start(&vbo->base.base.vma_node);
=20
 		dirty->method =3D VMW_BO_DIRTY_MKWRITE;
=20
@@ -362,7 +362,7 @@ vm_fault_t vmw_bo_vm_mkwrite(struct vm_fault *vmf)
 	if (ret)
 		return ret;
=20
-	page_offset =3D vmf->pgoff - drm_vma_node_start(&bo->vma_node);
+	page_offset =3D vmf->pgoff - drm_vma_node_start(&bo->base.vma_node);
 	if (unlikely(page_offset >=3D bo->num_pages)) {
 		ret =3D VM_FAULT_SIGBUS;
 		goto out_unlock;
@@ -378,7 +378,7 @@ vm_fault_t vmw_bo_vm_mkwrite(struct vm_fault *vmf)
 	}
=20
 out_unlock:
-	reservation_object_unlock(bo->resv);
+	dma_resv_unlock(bo->base.resv);
 	return ret;
 }
=20
@@ -412,6 +412,6 @@ vm_fault_t vmw_bo_vm_fault(struct vm_fault *vmf)
 	if (ret =3D=3D VM_FAULT_RETRY && !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT=
))
 		return ret;
=20
-	reservation_object_unlock(bo->resv);
+	dma_resv_unlock(bo->base.resv);
 	return ret;
 }
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c b/drivers/gpu/drm/v=
mwgfx/vmwgfx_resource.c
index e4c97a4cf2ff..328ad46076ff 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
@@ -40,11 +40,24 @@
 void vmw_resource_mob_attach(struct vmw_resource *res)
 {
 	struct vmw_buffer_object *backup =3D res->backup;
+	struct rb_node **new =3D &backup->res_tree.rb_node, *parent =3D NULL;
=20
 	dma_resv_assert_held(res->backup->base.base.resv);
 	res->used_prio =3D (res->res_dirty) ? res->func->dirty_prio :
 		res->func->prio;
-	list_add_tail(&res->mob_head, &backup->res_list);
+
+	while (*new) {
+		struct vmw_resource *this =3D
+			container_of(*new, struct vmw_resource, mob_node);
+
+		parent =3D *new;
+		new =3D (res->backup_offset < this->backup_offset) ?
+			&((*new)->rb_left) : &((*new)->rb_right);
+	}
+
+	rb_link_node(&res->mob_node, parent, new);
+	rb_insert_color(&res->mob_node, &backup->res_tree);
+
 	vmw_bo_prio_add(backup, res->used_prio);
 }
=20
@@ -58,7 +71,8 @@ void vmw_resource_mob_detach(struct vmw_resource *res)
=20
 	dma_resv_assert_held(backup->base.base.resv);
 	if (vmw_resource_mob_attached(res)) {
-		list_del_init(&res->mob_head);
+		rb_erase(&res->mob_node, &backup->res_tree);
+		RB_CLEAR_NODE(&res->mob_node);
 		vmw_bo_prio_del(backup, res->used_prio);
 	}
 }
@@ -204,8 +218,8 @@ int vmw_resource_init(struct vmw_private *dev_priv, s=
truct vmw_resource *res,
 	res->res_free =3D res_free;
 	res->dev_priv =3D dev_priv;
 	res->func =3D func;
+	RB_CLEAR_NODE(&res->mob_node);
 	INIT_LIST_HEAD(&res->lru_head);
-	INIT_LIST_HEAD(&res->mob_head);
 	INIT_LIST_HEAD(&res->binding_head);
 	res->id =3D -1;
 	res->backup =3D NULL;
@@ -754,19 +768,20 @@ int vmw_resource_validate(struct vmw_resource *res,=
 bool intr)
  */
 void vmw_resource_unbind_list(struct vmw_buffer_object *vbo)
 {
-
-	struct vmw_resource *res, *next;
 	struct ttm_validate_buffer val_buf =3D {
 		.bo =3D &vbo->base,
 		.num_shared =3D 0
 	};
=20
 	dma_resv_assert_held(vbo->base.base.resv);
-	list_for_each_entry_safe(res, next, &vbo->res_list, mob_head) {
-		if (!res->func->unbind)
-			continue;
+	while (!RB_EMPTY_ROOT(&vbo->res_tree)) {
+		struct rb_node *node =3D vbo->res_tree.rb_node;
+		struct vmw_resource *res =3D
+			container_of(node, struct vmw_resource, mob_node);
+
+		if (!WARN_ON_ONCE(!res->func->unbind))
+			(void) res->func->unbind(res, res->res_dirty, &val_buf);
=20
-		(void) res->func->unbind(res, res->res_dirty, &val_buf);
 		res->backup_dirty =3D true;
 		res->res_dirty =3D false;
 		vmw_resource_mob_detach(res);
--=20
2.20.1


