Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED55FC4CED0
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 877F621924
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="BShPzOoK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 877F621924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2B706B02AA; Wed, 18 Sep 2019 08:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D03206B02AC; Wed, 18 Sep 2019 08:59:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCAE76B02AD; Wed, 18 Sep 2019 08:59:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0007.hostedemail.com [216.40.44.7])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF3C6B02AA
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 08:59:39 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 18454824376D
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:39 +0000 (UTC)
X-FDA: 75948048078.19.talk70_54211f3a06c3b
X-HE-Tag: talk70_54211f3a06c3b
X-Filterd-Recvd-Size: 27557
Received: from pio-pvt-msa3.bahnhof.se (pio-pvt-msa3.bahnhof.se [79.136.2.42])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:38 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTP id 62C773F872;
	Wed, 18 Sep 2019 14:59:31 +0200 (CEST)
Authentication-Results: pio-pvt-msa3.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=BShPzOoK;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa3.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa3.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vC88il-KpaU4; Wed, 18 Sep 2019 14:59:26 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTPA id 0CB283F868;
	Wed, 18 Sep 2019 14:59:26 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 305CE3605DF;
	Wed, 18 Sep 2019 14:59:25 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568811565; bh=aCZQT2v8Wee6NSIhnf4v4kqWqhCp27Ghfw4lWQiUTQI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=BShPzOoKeKN+XHXDwmIMwF9OsI/uz986Chjn3FuZ7ND9NOgn860axH4SMB8p++TPr
	 L11+eLDZyp4CJDzRXoe/0zZYeptl7R3ziVuqIMPnTPE4kXJ0JSLyggIgl0kWezwNRs
	 tUYBD9ZLN85hzp57lHgV6mKADnFpY2eXRbI7VI30=
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
Subject: [PATCH 7/7] drm/vmwgfx: Add surface dirty-tracking callbacks
Date: Wed, 18 Sep 2019 14:59:14 +0200
Message-Id: <20190918125914.38497-8-thomas_os@shipmail.org>
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

Add the callbacks necessary to implement emulated coherent memory for
surfaces. Add a flag to the gb_surface_create ioctl to indicate that
surface memory should be coherent.
Also bump the drm minor version to signal the availability of coherent
surfaces.

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
 .../device_include/svga3d_surfacedefs.h       | 233 ++++++++++-
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h           |   4 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_surface.c       | 395 +++++++++++++++++-
 include/uapi/drm/vmwgfx_drm.h                 |   4 +-
 4 files changed, 629 insertions(+), 7 deletions(-)

diff --git a/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h b=
/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h
index f2bfd3d80598..61414f105c67 100644
--- a/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h
+++ b/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h
@@ -1280,7 +1280,6 @@ svga3dsurface_get_pixel_offset(SVGA3dSurfaceFormat =
format,
 	return offset;
 }
=20
-
 static inline u32
 svga3dsurface_get_image_offset(SVGA3dSurfaceFormat format,
 			       surf_size_struct baseLevelSize,
@@ -1375,4 +1374,236 @@ svga3dsurface_is_screen_target_format(SVGA3dSurfa=
ceFormat format)
 	return svga3dsurface_is_dx_screen_target_format(format);
 }
=20
+/**
+ * struct svga3dsurface_mip - Mimpmap level information
+ * @bytes: Bytes required in the backing store of this mipmap level.
+ * @img_stride: Byte stride per image.
+ * @row_stride: Byte stride per block row.
+ * @size: The size of the mipmap.
+ */
+struct svga3dsurface_mip {
+	size_t bytes;
+	size_t img_stride;
+	size_t row_stride;
+	struct drm_vmw_size size;
+
+};
+
+/**
+ * struct svga3dsurface_cache - Cached surface information
+ * @desc: Pointer to the surface descriptor
+ * @mip: Array of mipmap level information. Valid size is @num_mip_level=
s.
+ * @mip_chain_bytes: Bytes required in the backing store for the whole c=
hain
+ * of mip levels.
+ * @sheet_bytes: Bytes required in the backing store for a sheet
+ * representing a single sample.
+ * @num_mip_levels: Valid size of the @mip array. Number of mipmap level=
s in
+ * a chain.
+ * @num_layers: Number of slices in an array texture or number of faces =
in
+ * a cubemap texture.
+ */
+struct svga3dsurface_cache {
+	const struct svga3d_surface_desc *desc;
+	struct svga3dsurface_mip mip[DRM_VMW_MAX_MIP_LEVELS];
+	size_t mip_chain_bytes;
+	size_t sheet_bytes;
+	u32 num_mip_levels;
+	u32 num_layers;
+};
+
+/**
+ * struct svga3dsurface_loc - Surface location
+ * @sub_resource: Surface subresource. Defined as layer * num_mip_levels=
 +
+ * mip_level.
+ * @x: X coordinate.
+ * @y: Y coordinate.
+ * @z: Z coordinate.
+ */
+struct svga3dsurface_loc {
+	u32 sub_resource;
+	u32 x, y, z;
+};
+
+/**
+ * svga3dsurface_subres - Compute the subresource from layer and mipmap.
+ * @cache: Surface layout data.
+ * @mip_level: The mipmap level.
+ * @layer: The surface layer (face or array slice).
+ *
+ * Return: The subresource.
+ */
+static inline u32 svga3dsurface_subres(const struct svga3dsurface_cache =
*cache,
+				       u32 mip_level, u32 layer)
+{
+	return cache->num_mip_levels * layer + mip_level;
+}
+
+/**
+ * svga3dsurface_setup_cache - Build a surface cache entry
+ * @size: The surface base level dimensions.
+ * @format: The surface format.
+ * @num_mip_levels: Number of mipmap levels.
+ * @num_layers: Number of layers.
+ * @cache: Pointer to a struct svga3dsurface_cach object to be filled in=
.
+ *
+ * Return: Zero on success, -EINVAL on invalid surface layout.
+ */
+static inline int svga3dsurface_setup_cache(const struct drm_vmw_size *s=
ize,
+					    SVGA3dSurfaceFormat format,
+					    u32 num_mip_levels,
+					    u32 num_layers,
+					    u32 num_samples,
+					    struct svga3dsurface_cache *cache)
+{
+	const struct svga3d_surface_desc *desc;
+	u32 i;
+
+	memset(cache, 0, sizeof(*cache));
+	cache->desc =3D desc =3D svga3dsurface_get_desc(format);
+	cache->num_mip_levels =3D num_mip_levels;
+	cache->num_layers =3D num_layers;
+	for (i =3D 0; i < cache->num_mip_levels; i++) {
+		struct svga3dsurface_mip *mip =3D &cache->mip[i];
+
+		mip->size =3D svga3dsurface_get_mip_size(*size, i);
+		mip->bytes =3D svga3dsurface_get_image_buffer_size
+			(desc, &mip->size, 0);
+		mip->row_stride =3D
+			__KERNEL_DIV_ROUND_UP(mip->size.width,
+					      desc->block_size.width) *
+			desc->bytes_per_block * num_samples;
+		if (!mip->row_stride)
+			goto invalid_dim;
+
+		mip->img_stride =3D
+			__KERNEL_DIV_ROUND_UP(mip->size.height,
+					      desc->block_size.height) *
+			mip->row_stride;
+		if (!mip->img_stride)
+			goto invalid_dim;
+
+		cache->mip_chain_bytes +=3D mip->bytes;
+	}
+	cache->sheet_bytes =3D cache->mip_chain_bytes * num_layers;
+	if (!cache->sheet_bytes)
+		goto invalid_dim;
+
+	return 0;
+
+invalid_dim:
+	VMW_DEBUG_USER("Invalid surface layout for dirty tracking.\n");
+	return -EINVAL;
+}
+
+/**
+ * svga3dsurface_get_loc - Get a surface location from an offset into th=
e
+ * backing store
+ * @cache: Surface layout data.
+ * @loc: Pointer to a struct svga3dsurface_loc to be filled in.
+ * @offset: Offset into the surface backing store.
+ */
+static inline void
+svga3dsurface_get_loc(const struct svga3dsurface_cache *cache,
+		      struct svga3dsurface_loc *loc,
+		      size_t offset)
+{
+	const struct svga3dsurface_mip *mip =3D &cache->mip[0];
+	const struct svga3d_surface_desc *desc =3D cache->desc;
+	u32 layer;
+	int i;
+
+	if (offset >=3D cache->sheet_bytes)
+		offset %=3D cache->sheet_bytes;
+
+	layer =3D offset / cache->mip_chain_bytes;
+	offset -=3D layer * cache->mip_chain_bytes;
+	for (i =3D 0; i < cache->num_mip_levels; ++i, ++mip) {
+		if (mip->bytes > offset)
+			break;
+		offset -=3D mip->bytes;
+	}
+
+	loc->sub_resource =3D svga3dsurface_subres(cache, i, layer);
+	loc->z =3D offset / mip->img_stride;
+	offset -=3D loc->z * mip->img_stride;
+	loc->z *=3D desc->block_size.depth;
+	loc->y =3D offset / mip->row_stride;
+	offset -=3D loc->y * mip->row_stride;
+	loc->y *=3D desc->block_size.height;
+	loc->x =3D offset / desc->bytes_per_block;
+	loc->x *=3D desc->block_size.width;
+}
+
+/**
+ * svga3dsurface_inc_loc - Clamp increment a surface location with one b=
lock
+ * size
+ * in each dimension.
+ * @loc: Pointer to a struct svga3dsurface_loc to be incremented.
+ *
+ * When computing the size of a range as size =3D end - start, the range=
 does not
+ * include the end element. However a location representing the last byt=
e
+ * of a touched region in the backing store *is* included in the range.
+ * This function modifies such a location to match the end definition
+ * given as start + size which is the one used in a SVGA3dBox.
+ */
+static inline void
+svga3dsurface_inc_loc(const struct svga3dsurface_cache *cache,
+		      struct svga3dsurface_loc *loc)
+{
+	const struct svga3d_surface_desc *desc =3D cache->desc;
+	u32 mip =3D loc->sub_resource % cache->num_mip_levels;
+	const struct drm_vmw_size *size =3D &cache->mip[mip].size;
+
+	loc->sub_resource++;
+	loc->x +=3D desc->block_size.width;
+	if (loc->x > size->width)
+		loc->x =3D size->width;
+	loc->y +=3D desc->block_size.height;
+	if (loc->y > size->height)
+		loc->y =3D size->height;
+	loc->z +=3D desc->block_size.depth;
+	if (loc->z > size->depth)
+		loc->z =3D size->depth;
+}
+
+/**
+ * svga3dsurface_min_loc - The start location in a subresource
+ * @cache: Surface layout data.
+ * @sub_resource: The subresource.
+ * @loc: Pointer to a struct svga3dsurface_loc to be filled in.
+ */
+static inline void
+svga3dsurface_min_loc(const struct svga3dsurface_cache *cache,
+		      u32 sub_resource,
+		      struct svga3dsurface_loc *loc)
+{
+	loc->sub_resource =3D sub_resource;
+	loc->x =3D loc->y =3D loc->z =3D 0;
+}
+
+/**
+ * svga3dsurface_min_loc - The end location in a subresource
+ * @cache: Surface layout data.
+ * @sub_resource: The subresource.
+ * @loc: Pointer to a struct svga3dsurface_loc to be filled in.
+ *
+ * Following the end definition given in svga3dsurface_inc_loc(),
+ * Compute the end location of a surface subresource.
+ */
+static inline void
+svga3dsurface_max_loc(const struct svga3dsurface_cache *cache,
+		      u32 sub_resource,
+		      struct svga3dsurface_loc *loc)
+{
+	const struct drm_vmw_size *size;
+	u32 mip;
+
+	loc->sub_resource =3D sub_resource + 1;
+	mip =3D sub_resource % cache->num_mip_levels;
+	size =3D &cache->mip[mip].size;
+	loc->x =3D size->width;
+	loc->y =3D size->height;
+	loc->z =3D size->depth;
+}
+
 #endif /* _SVGA3D_SURFACEDEFS_H_ */
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h b/drivers/gpu/drm/vmwgfx=
/vmwgfx_drv.h
index 729a2e93acf1..f5261e1c96d7 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
@@ -56,9 +56,9 @@
=20
=20
 #define VMWGFX_DRIVER_NAME "vmwgfx"
-#define VMWGFX_DRIVER_DATE "20180704"
+#define VMWGFX_DRIVER_DATE "20190328"
 #define VMWGFX_DRIVER_MAJOR 2
-#define VMWGFX_DRIVER_MINOR 15
+#define VMWGFX_DRIVER_MINOR 16
 #define VMWGFX_DRIVER_PATCHLEVEL 0
 #define VMWGFX_FIFO_STATIC_SIZE (1024*1024)
 #define VMWGFX_MAX_RELOCATIONS 2048
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_surface.c b/drivers/gpu/drm/vm=
wgfx/vmwgfx_surface.c
index 29d8794f0421..876bada5b35e 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_surface.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_surface.c
@@ -68,6 +68,20 @@ struct vmw_surface_offset {
 	uint32_t bo_offset;
 };
=20
+/**
+ * vmw_surface_dirty - Surface dirty-tracker
+ * @cache: Cached layout information of the surface.
+ * @size: Accounting size for the struct vmw_surface_dirty.
+ * @num_subres: Number of subresources.
+ * @boxes: Array of SVGA3dBoxes indicating dirty regions. One per subres=
ource.
+ */
+struct vmw_surface_dirty {
+	struct svga3dsurface_cache cache;
+	size_t size;
+	u32 num_subres;
+	SVGA3dBox boxes[0];
+};
+
 static void vmw_user_surface_free(struct vmw_resource *res);
 static struct vmw_resource *
 vmw_user_surface_base_to_res(struct ttm_base_object *base);
@@ -96,6 +110,13 @@ vmw_gb_surface_reference_internal(struct drm_device *=
dev,
 				  struct drm_vmw_gb_surface_ref_ext_rep *rep,
 				  struct drm_file *file_priv);
=20
+static void vmw_surface_dirty_free(struct vmw_resource *res);
+static int vmw_surface_dirty_alloc(struct vmw_resource *res);
+static int vmw_surface_dirty_sync(struct vmw_resource *res);
+static void vmw_surface_dirty_range_add(struct vmw_resource *res, size_t=
 start,
+					size_t end);
+static int vmw_surface_clean(struct vmw_resource *res);
+
 static const struct vmw_user_resource_conv user_surface_conv =3D {
 	.object_type =3D VMW_RES_SURFACE,
 	.base_obj_to_res =3D vmw_user_surface_base_to_res,
@@ -133,7 +154,12 @@ static const struct vmw_res_func vmw_gb_surface_func=
 =3D {
 	.create =3D vmw_gb_surface_create,
 	.destroy =3D vmw_gb_surface_destroy,
 	.bind =3D vmw_gb_surface_bind,
-	.unbind =3D vmw_gb_surface_unbind
+	.unbind =3D vmw_gb_surface_unbind,
+	.dirty_alloc =3D vmw_surface_dirty_alloc,
+	.dirty_free =3D vmw_surface_dirty_free,
+	.dirty_sync =3D vmw_surface_dirty_sync,
+	.dirty_range_add =3D vmw_surface_dirty_range_add,
+	.clean =3D vmw_surface_clean,
 };
=20
 /**
@@ -641,6 +667,7 @@ static void vmw_user_surface_free(struct vmw_resource=
 *res)
 	struct vmw_private *dev_priv =3D srf->res.dev_priv;
 	uint32_t size =3D user_srf->size;
=20
+	WARN_ON_ONCE(res->dirty);
 	if (user_srf->master)
 		drm_master_put(&user_srf->master);
 	kfree(srf->offsets);
@@ -1168,10 +1195,16 @@ static int vmw_gb_surface_bind(struct vmw_resourc=
e *res,
 		cmd2->header.id =3D SVGA_3D_CMD_UPDATE_GB_SURFACE;
 		cmd2->header.size =3D sizeof(cmd2->body);
 		cmd2->body.sid =3D res->id;
-		res->backup_dirty =3D false;
 	}
 	vmw_fifo_commit(dev_priv, submit_size);
=20
+	if (res->backup->dirty && res->backup_dirty) {
+		/* We've just made a full upload. Cear dirty regions. */
+		vmw_bo_dirty_clear_res(res);
+	}
+
+	res->backup_dirty =3D false;
+
 	return 0;
 }
=20
@@ -1636,7 +1669,8 @@ vmw_gb_surface_define_internal(struct drm_device *d=
ev,
 			}
 		}
 	} else if (req->base.drm_surface_flags &
-		   drm_vmw_surface_flag_create_buffer)
+		   (drm_vmw_surface_flag_create_buffer |
+		    drm_vmw_surface_flag_coherent))
 		ret =3D vmw_user_bo_alloc(dev_priv, tfile,
 					res->backup_size,
 					req->base.drm_surface_flags &
@@ -1650,6 +1684,26 @@ vmw_gb_surface_define_internal(struct drm_device *=
dev,
 		goto out_unlock;
 	}
=20
+	if (req->base.drm_surface_flags & drm_vmw_surface_flag_coherent) {
+		struct vmw_buffer_object *backup =3D res->backup;
+
+		ttm_bo_reserve(&backup->base, false, false, NULL);
+		if (!res->func->dirty_alloc)
+			ret =3D -EINVAL;
+		if (!ret)
+			ret =3D vmw_bo_dirty_add(backup);
+		if (!ret) {
+			res->coherent =3D true;
+			ret =3D res->func->dirty_alloc(res);
+		}
+		ttm_bo_unreserve(&backup->base);
+		if (ret) {
+			vmw_resource_unreference(&res);
+			goto out_unlock;
+		}
+
+	}
+
 	tmp =3D vmw_resource_reference(res);
 	ret =3D ttm_prime_object_init(tfile, res->backup_size, &user_srf->prime=
,
 				    req->base.drm_surface_flags &
@@ -1758,3 +1812,338 @@ vmw_gb_surface_reference_internal(struct drm_devi=
ce *dev,
=20
 	return ret;
 }
+
+/**
+ * vmw_subres_dirty_add - Add a dirty region to a subresource
+ * @dirty: The surfaces's dirty tracker.
+ * @loc_start: The location corresponding to the start of the region.
+ * @loc_end: The location corresponding to the end of the region.
+ *
+ * As we are assuming that @loc_start and @loc_end represent a sequentia=
l
+ * range of backing store memory, if the region spans multiple lines the=
n
+ * regardless of the x coordinate, the full lines are dirtied.
+ * Correspondingly if the region spans multiple z slices, then full rath=
er
+ * than partial z slices are dirtied.
+ */
+static void vmw_subres_dirty_add(struct vmw_surface_dirty *dirty,
+				 const struct svga3dsurface_loc *loc_start,
+				 const struct svga3dsurface_loc *loc_end)
+{
+	const struct svga3dsurface_cache *cache =3D &dirty->cache;
+	SVGA3dBox *box =3D &dirty->boxes[loc_start->sub_resource];
+	u32 mip =3D loc_start->sub_resource % cache->num_mip_levels;
+	const struct drm_vmw_size *size =3D &cache->mip[mip].size;
+	u32 box_c2 =3D box->z + box->d;
+
+	if (WARN_ON(loc_start->sub_resource >=3D dirty->num_subres))
+		return;
+
+	if (box->d =3D=3D 0 || box->z > loc_start->z)
+		box->z =3D loc_start->z;
+	if (box_c2 < loc_end->z)
+		box->d =3D loc_end->z - box->z;
+
+	if (loc_start->z + 1 =3D=3D loc_end->z) {
+		box_c2 =3D box->y + box->h;
+		if (box->h =3D=3D 0 || box->y > loc_start->y)
+			box->y =3D loc_start->y;
+		if (box_c2 < loc_end->y)
+			box->h =3D loc_end->y - box->y;
+
+		if (loc_start->y + 1 =3D=3D loc_end->y) {
+			box_c2 =3D box->x + box->w;
+			if (box->w =3D=3D 0 || box->x > loc_start->x)
+				box->x =3D loc_start->x;
+			if (box_c2 < loc_end->x)
+				box->w =3D loc_end->x - box->x;
+		} else {
+			box->x =3D 0;
+			box->w =3D size->width;
+		}
+	} else {
+		box->y =3D 0;
+		box->h =3D size->height;
+		box->x =3D 0;
+		box->w =3D size->width;
+	}
+}
+
+/**
+ * vmw_subres_dirty_full - Mark a full subresource as dirty
+ * @dirty: The surface's dirty tracker.
+ * @subres: The subresource
+ */
+static void vmw_subres_dirty_full(struct vmw_surface_dirty *dirty, u32 s=
ubres)
+{
+	const struct svga3dsurface_cache *cache =3D &dirty->cache;
+	u32 mip =3D subres % cache->num_mip_levels;
+	const struct drm_vmw_size *size =3D &cache->mip[mip].size;
+	SVGA3dBox *box =3D &dirty->boxes[subres];
+
+	box->x =3D 0;
+	box->y =3D 0;
+	box->z =3D 0;
+	box->w =3D size->width;
+	box->h =3D size->height;
+	box->d =3D size->depth;
+}
+
+/*
+ * vmw_surface_tex_dirty_add_range - The dirty_add_range callback for te=
xture
+ * surfaces.
+ */
+static void vmw_surface_tex_dirty_range_add(struct vmw_resource *res,
+					    size_t start, size_t end)
+{
+	struct vmw_surface_dirty *dirty =3D
+		(struct vmw_surface_dirty *) res->dirty;
+	size_t backup_end =3D res->backup_offset + res->backup_size;
+	struct svga3dsurface_loc loc1, loc2;
+	const struct svga3dsurface_cache *cache;
+
+	start =3D max_t(size_t, start, res->backup_offset) - res->backup_offset=
;
+	end =3D min(end, backup_end) - res->backup_offset;
+	cache =3D &dirty->cache;
+	svga3dsurface_get_loc(cache, &loc1, start);
+	svga3dsurface_get_loc(cache, &loc2, end - 1);
+	svga3dsurface_inc_loc(cache, &loc2);
+
+	if (loc1.sub_resource + 1 =3D=3D loc2.sub_resource) {
+		/* Dirty range covers a single sub-resource */
+		vmw_subres_dirty_add(dirty, &loc1, &loc2);
+	} else {
+		/* Dirty range covers multiple sub-resources */
+		struct svga3dsurface_loc loc_min, loc_max;
+		u32 sub_res =3D loc1.sub_resource;
+
+		svga3dsurface_max_loc(cache, loc1.sub_resource, &loc_max);
+		vmw_subres_dirty_add(dirty, &loc1, &loc_max);
+		svga3dsurface_min_loc(cache, loc2.sub_resource - 1, &loc_min);
+		vmw_subres_dirty_add(dirty, &loc_min, &loc2);
+		for (sub_res =3D loc1.sub_resource + 1;
+		     sub_res < loc2.sub_resource - 1; ++sub_res)
+			vmw_subres_dirty_full(dirty, sub_res);
+	}
+}
+
+/*
+ * vmw_surface_tex_dirty_add_range - The dirty_add_range callback for bu=
ffer
+ * surfaces.
+ */
+static void vmw_surface_buf_dirty_range_add(struct vmw_resource *res,
+					    size_t start, size_t end)
+{
+	struct vmw_surface_dirty *dirty =3D
+		(struct vmw_surface_dirty *) res->dirty;
+	const struct svga3dsurface_cache *cache =3D &dirty->cache;
+	size_t backup_end =3D res->backup_offset + cache->mip_chain_bytes;
+	SVGA3dBox *box =3D &dirty->boxes[0];
+	u32 box_c2;
+
+	box->h =3D box->d =3D 1;
+	start =3D max_t(size_t, start, res->backup_offset) - res->backup_offset=
;
+	end =3D min(end, backup_end) - res->backup_offset;
+	box_c2 =3D box->x + box->w;
+	if (box->w =3D=3D 0 || box->x > start)
+		box->x =3D start;
+	if (box_c2 < end)
+		box->w =3D end - box->x;
+}
+
+/*
+ * vmw_surface_tex_dirty_add_range - The dirty_add_range callback for su=
rfaces
+ */
+static void vmw_surface_dirty_range_add(struct vmw_resource *res, size_t=
 start,
+					size_t end)
+{
+	struct vmw_surface *srf =3D vmw_res_to_srf(res);
+
+	if (WARN_ON(end <=3D res->backup_offset ||
+		    start >=3D res->backup_offset + res->backup_size))
+		return;
+
+	if (srf->format =3D=3D SVGA3D_BUFFER)
+		vmw_surface_buf_dirty_range_add(res, start, end);
+	else
+		vmw_surface_tex_dirty_range_add(res, start, end);
+}
+
+/*
+ * vmw_surface_dirty_sync - The surface's dirty_sync callback.
+ */
+static int vmw_surface_dirty_sync(struct vmw_resource *res)
+{
+	struct vmw_private *dev_priv =3D res->dev_priv;
+	bool has_dx =3D 0;
+	u32 i, num_dirty;
+	struct vmw_surface_dirty *dirty =3D
+		(struct vmw_surface_dirty *) res->dirty;
+	size_t alloc_size;
+	const struct svga3dsurface_cache *cache =3D &dirty->cache;
+	struct {
+		SVGA3dCmdHeader header;
+		SVGA3dCmdDXUpdateSubResource body;
+	} *cmd1;
+	struct {
+		SVGA3dCmdHeader header;
+		SVGA3dCmdUpdateGBImage body;
+	} *cmd2;
+	void *cmd;
+
+	num_dirty =3D 0;
+	for (i =3D 0; i < dirty->num_subres; ++i) {
+		const SVGA3dBox *box =3D &dirty->boxes[i];
+
+		if (box->d)
+			num_dirty++;
+	}
+
+	if (!num_dirty)
+		goto out;
+
+	alloc_size =3D num_dirty * ((has_dx) ? sizeof(*cmd1) : sizeof(*cmd2));
+	cmd =3D VMW_FIFO_RESERVE(dev_priv, alloc_size);
+	if (!cmd)
+		return -ENOMEM;
+
+	cmd1 =3D cmd;
+	cmd2 =3D cmd;
+
+	for (i =3D 0; i < dirty->num_subres; ++i) {
+		const SVGA3dBox *box =3D &dirty->boxes[i];
+
+		if (!box->d)
+			continue;
+
+		/*
+		 * DX_UPDATE_SUBRESOURCE is aware of array surfaces.
+		 * UPDATE_GB_IMAGE is not.
+		 */
+		if (has_dx) {
+			cmd1->header.id =3D SVGA_3D_CMD_DX_UPDATE_SUBRESOURCE;
+			cmd1->header.size =3D sizeof(cmd1->body);
+			cmd1->body.sid =3D res->id;
+			cmd1->body.subResource =3D i;
+			cmd1->body.box =3D *box;
+			cmd1++;
+		} else {
+			cmd2->header.id =3D SVGA_3D_CMD_UPDATE_GB_IMAGE;
+			cmd2->header.size =3D sizeof(cmd2->body);
+			cmd2->body.image.sid =3D res->id;
+			cmd2->body.image.face =3D i / cache->num_mip_levels;
+			cmd2->body.image.mipmap =3D i -
+				(cache->num_mip_levels * cmd2->body.image.face);
+			cmd2->body.box =3D *box;
+			cmd2++;
+		}
+
+	}
+	vmw_fifo_commit(dev_priv, alloc_size);
+ out:
+	memset(&dirty->boxes[0], 0, sizeof(dirty->boxes[0]) *
+	       dirty->num_subres);
+
+	return 0;
+}
+
+/*
+ * vmw_surface_dirty_alloc - The surface's dirty_alloc callback.
+ */
+static int vmw_surface_dirty_alloc(struct vmw_resource *res)
+{
+	struct vmw_surface *srf =3D vmw_res_to_srf(res);
+	struct vmw_surface_dirty *dirty;
+	u32 num_layers =3D 1;
+	u32 num_mip;
+	u32 num_subres;
+	u32 num_samples;
+	size_t dirty_size, acc_size;
+	static struct ttm_operation_ctx ctx =3D {
+		.interruptible =3D false,
+		.no_wait_gpu =3D false
+	};
+	int ret;
+
+	if (srf->array_size)
+		num_layers =3D srf->array_size;
+	else if (srf->flags & SVGA3D_SURFACE_CUBEMAP)
+		num_layers *=3D SVGA3D_MAX_SURFACE_FACES;
+
+	num_mip =3D srf->mip_levels[0];
+	if (!num_mip)
+		num_mip =3D 1;
+
+	num_subres =3D num_layers * num_mip;
+	dirty_size =3D sizeof(*dirty) + num_subres * sizeof(dirty->boxes[0]);
+	acc_size =3D ttm_round_pot(dirty_size);
+	ret =3D ttm_mem_global_alloc(vmw_mem_glob(res->dev_priv),
+				   acc_size, &ctx);
+	if (ret) {
+		VMW_DEBUG_USER("Out of graphics memory for surface "
+			       "dirty tracker.\n");
+		return ret;
+	}
+
+	dirty =3D kvzalloc(dirty_size, GFP_KERNEL);
+	if (!dirty) {
+		ret =3D -ENOMEM;
+		goto out_no_dirty;
+	}
+
+	num_samples =3D max_t(u32, 1, srf->multisample_count);
+	ret =3D svga3dsurface_setup_cache(&srf->base_size, srf->format, num_mip=
,
+					num_layers, num_samples, &dirty->cache);
+	if (ret)
+		goto out_no_cache;
+
+	dirty->num_subres =3D num_subres;
+	dirty->size =3D acc_size;
+	res->dirty =3D (struct vmw_resource_dirty *) dirty;
+
+	return 0;
+
+out_no_cache:
+	kvfree(dirty);
+out_no_dirty:
+	ttm_mem_global_free(vmw_mem_glob(res->dev_priv), acc_size);
+	return ret;
+}
+
+/*
+ * vmw_surface_dirty_free - The surface's dirty_free callback
+ */
+static void vmw_surface_dirty_free(struct vmw_resource *res)
+{
+	struct vmw_surface_dirty *dirty =3D
+		(struct vmw_surface_dirty *) res->dirty;
+	size_t acc_size =3D dirty->size;
+
+	kvfree(dirty);
+	ttm_mem_global_free(vmw_mem_glob(res->dev_priv), acc_size);
+	res->dirty =3D NULL;
+}
+
+/*
+ * vmw_surface_clean - The surface's clean callback
+ */
+static int vmw_surface_clean(struct vmw_resource *res)
+{
+	struct vmw_private *dev_priv =3D res->dev_priv;
+	size_t alloc_size;
+	struct {
+		SVGA3dCmdHeader header;
+		SVGA3dCmdReadbackGBSurface body;
+	} *cmd;
+
+	alloc_size =3D sizeof(*cmd);
+	cmd =3D VMW_FIFO_RESERVE(dev_priv, alloc_size);
+	if (!cmd)
+		return -ENOMEM;
+
+	cmd->header.id =3D SVGA_3D_CMD_READBACK_GB_SURFACE;
+	cmd->header.size =3D sizeof(cmd->body);
+	cmd->body.sid =3D res->id;
+	vmw_fifo_commit(dev_priv, alloc_size);
+
+	return 0;
+}
diff --git a/include/uapi/drm/vmwgfx_drm.h b/include/uapi/drm/vmwgfx_drm.=
h
index 399f58317cff..02cab33f2f25 100644
--- a/include/uapi/drm/vmwgfx_drm.h
+++ b/include/uapi/drm/vmwgfx_drm.h
@@ -891,11 +891,13 @@ struct drm_vmw_shader_arg {
  *                                      surface.
  * @drm_vmw_surface_flag_create_buffer: Create a backup buffer if none i=
s
  *                                      given.
+ * @drm_vmw_surface_flag_coherent:      Back surface with coherent memor=
y.
  */
 enum drm_vmw_surface_flags {
 	drm_vmw_surface_flag_shareable =3D (1 << 0),
 	drm_vmw_surface_flag_scanout =3D (1 << 1),
-	drm_vmw_surface_flag_create_buffer =3D (1 << 2)
+	drm_vmw_surface_flag_create_buffer =3D (1 << 2),
+	drm_vmw_surface_flag_coherent =3D (1 << 3),
 };
=20
 /**
--=20
2.20.1


