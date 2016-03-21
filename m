Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id CE1CD6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:51:15 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id l68so120566920wml.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:51:15 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id r76si14427507wmg.70.2016.03.21.05.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 05:51:14 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r129so9787818wmr.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:51:13 -0700 (PDT)
Date: Mon, 21 Mar 2016 13:51:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, fs: remove remaining PAGE_CACHE_* and
 page_cache_{get,release} usage
Message-ID: <20160321125111.GD23066@dhcp22.suse.cz>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458561998-126622-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458561998-126622-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon 21-03-16 15:06:37, Kirill A. Shutemov wrote:
> Mostly direct substitution with occasional adjustment or removing
> outdated comments.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I haven't spotted anything wrong here

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  Documentation/filesystems/cramfs.txt               |  2 +-
>  Documentation/filesystems/tmpfs.txt                |  2 +-
>  Documentation/filesystems/vfs.txt                  |  4 ++--
>  arch/parisc/mm/init.c                              |  2 +-
>  block/bio.c                                        |  4 ++--
>  drivers/block/drbd/drbd_int.h                      |  4 ++--
>  drivers/staging/lustre/include/linux/lnet/types.h  |  2 +-
>  drivers/staging/lustre/lnet/selftest/selftest.h    |  4 ++--
>  drivers/staging/lustre/lustre/include/lu_object.h  |  2 +-
>  .../lustre/lustre/include/lustre/lustre_idl.h      |  4 ++--
>  drivers/staging/lustre/lustre/include/lustre_net.h |  4 ++--
>  drivers/staging/lustre/lustre/include/obd.h        |  2 +-
>  drivers/staging/lustre/lustre/llite/dir.c          |  5 ++---
>  drivers/staging/lustre/lustre/llite/rw.c           |  2 +-
>  drivers/staging/lustre/lustre/llite/vvp_io.c       |  2 +-
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  8 +++----
>  .../lustre/lustre/obdclass/linux/linux-obdo.c      |  1 -
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |  2 +-
>  fs/btrfs/check-integrity.c                         |  4 ++--
>  fs/btrfs/extent_io.c                               |  8 +++----
>  fs/btrfs/struct-funcs.c                            |  4 ++--
>  fs/btrfs/tests/extent-io-tests.c                   |  2 +-
>  fs/cifs/cifsglob.h                                 |  4 ++--
>  fs/cifs/file.c                                     |  2 +-
>  fs/cramfs/README                                   | 26 +++++++++++-----------
>  fs/cramfs/inode.c                                  |  2 +-
>  fs/dax.c                                           |  4 ++--
>  fs/ecryptfs/inode.c                                |  4 ++--
>  fs/ext2/dir.c                                      |  4 ++--
>  fs/ext4/ext4.h                                     |  4 ++--
>  fs/ext4/inode.c                                    |  2 +-
>  fs/ext4/mballoc.c                                  |  4 ++--
>  fs/ext4/readpage.c                                 |  2 +-
>  fs/hugetlbfs/inode.c                               |  2 +-
>  fs/mpage.c                                         |  2 +-
>  fs/ntfs/aops.c                                     |  2 +-
>  fs/ntfs/aops.h                                     |  2 +-
>  fs/ntfs/compress.c                                 | 21 +++++------------
>  fs/ntfs/dir.c                                      | 16 ++++++-------
>  fs/ntfs/file.c                                     |  2 +-
>  fs/ntfs/index.c                                    |  2 +-
>  fs/ntfs/inode.c                                    |  4 ++--
>  fs/ntfs/super.c                                    | 14 ++++++------
>  fs/ocfs2/aops.c                                    |  2 +-
>  fs/ocfs2/refcounttree.c                            |  2 +-
>  fs/reiserfs/journal.c                              |  2 +-
>  fs/squashfs/cache.c                                |  4 ++--
>  fs/squashfs/file.c                                 |  2 +-
>  fs/ubifs/file.c                                    |  2 +-
>  fs/ubifs/super.c                                   |  2 +-
>  fs/xfs/xfs_aops.c                                  |  8 +++----
>  fs/xfs/xfs_super.c                                 |  4 ++--
>  include/linux/backing-dev-defs.h                   |  2 +-
>  include/linux/mm.h                                 |  2 +-
>  include/linux/mm_types.h                           |  2 +-
>  include/linux/nfs_page.h                           |  4 ++--
>  include/linux/nilfs2_fs.h                          |  4 ++--
>  include/linux/pagemap.h                            |  3 +--
>  include/linux/sunrpc/svc.h                         |  2 +-
>  include/linux/swap.h                               |  2 +-
>  mm/gup.c                                           |  2 +-
>  mm/memory.c                                        |  1 -
>  mm/mincore.c                                       |  4 ++--
>  mm/swap.c                                          |  2 +-
>  net/sunrpc/xdr.c                                   |  2 +-
>  65 files changed, 122 insertions(+), 137 deletions(-)
> 
> diff --git a/Documentation/filesystems/cramfs.txt b/Documentation/filesystems/cramfs.txt
> index 31f53f0ab957..4006298f6707 100644
> --- a/Documentation/filesystems/cramfs.txt
> +++ b/Documentation/filesystems/cramfs.txt
> @@ -38,7 +38,7 @@ the update lasts only as long as the inode is cached in memory, after
>  which the timestamp reverts to 1970, i.e. moves backwards in time.
>  
>  Currently, cramfs must be written and read with architectures of the
> -same endianness, and can be read only by kernels with PAGE_CACHE_SIZE
> +same endianness, and can be read only by kernels with PAGE_SIZE
>  == 4096.  At least the latter of these is a bug, but it hasn't been
>  decided what the best fix is.  For the moment if you have larger pages
>  you can just change the #define in mkcramfs.c, so long as you don't
> diff --git a/Documentation/filesystems/tmpfs.txt b/Documentation/filesystems/tmpfs.txt
> index d392e1505f17..d9c11d25bf02 100644
> --- a/Documentation/filesystems/tmpfs.txt
> +++ b/Documentation/filesystems/tmpfs.txt
> @@ -60,7 +60,7 @@ size:      The limit of allocated bytes for this tmpfs instance. The
>             default is half of your physical RAM without swap. If you
>             oversize your tmpfs instances the machine will deadlock
>             since the OOM handler will not be able to free that memory.
> -nr_blocks: The same as size, but in blocks of PAGE_CACHE_SIZE.
> +nr_blocks: The same as size, but in blocks of PAGE_SIZE.
>  nr_inodes: The maximum number of inodes for this instance. The default
>             is half of the number of your physical RAM pages, or (on a
>             machine with highmem) the number of lowmem RAM pages,
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index b02a7d598258..4164bd6397a2 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -708,9 +708,9 @@ struct address_space_operations {
>  	from the address space.  This generally corresponds to either a
>  	truncation, punch hole  or a complete invalidation of the address
>  	space (in the latter case 'offset' will always be 0 and 'length'
> -	will be PAGE_CACHE_SIZE). Any private data associated with the page
> +	will be PAGE_SIZE). Any private data associated with the page
>  	should be updated to reflect this truncation.  If offset is 0 and
> -	length is PAGE_CACHE_SIZE, then the private data should be released,
> +	length is PAGE_SIZE, then the private data should be released,
>  	because the page must be able to be completely discarded.  This may
>  	be done by calling the ->releasepage function, but in this case the
>  	release MUST succeed.
> diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
> index 3c07d6b96877..6b3e7c6ee096 100644
> --- a/arch/parisc/mm/init.c
> +++ b/arch/parisc/mm/init.c
> @@ -22,7 +22,7 @@
>  #include <linux/swap.h>
>  #include <linux/unistd.h>
>  #include <linux/nodemask.h>	/* for node_online_map */
> -#include <linux/pagemap.h>	/* for release_pages and page_cache_release */
> +#include <linux/pagemap.h>	/* for release_pages */
>  #include <linux/compat.h>
>  
>  #include <asm/pgalloc.h>
> diff --git a/block/bio.c b/block/bio.c
> index 168531517694..807d25e466ec 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -1615,8 +1615,8 @@ static void bio_release_pages(struct bio *bio)
>   * the BIO and the offending pages and re-dirty the pages in process context.
>   *
>   * It is expected that bio_check_pages_dirty() will wholly own the BIO from
> - * here on.  It will run one page_cache_release() against each page and will
> - * run one bio_put() against the BIO.
> + * here on.  It will run one put_page() against each page and will run one
> + * bio_put() against the BIO.
>   */
>  
>  static void bio_dirty_fn(struct work_struct *work);
> diff --git a/drivers/block/drbd/drbd_int.h b/drivers/block/drbd/drbd_int.h
> index c227fd4cad75..7a1cf7eaa71d 100644
> --- a/drivers/block/drbd/drbd_int.h
> +++ b/drivers/block/drbd/drbd_int.h
> @@ -1327,8 +1327,8 @@ struct bm_extent {
>  #endif
>  #endif
>  
> -/* BIO_MAX_SIZE is 256 * PAGE_CACHE_SIZE,
> - * so for typical PAGE_CACHE_SIZE of 4k, that is (1<<20) Byte.
> +/* BIO_MAX_SIZE is 256 * PAGE_SIZE,
> + * so for typical PAGE_SIZE of 4k, that is (1<<20) Byte.
>   * Since we may live in a mixed-platform cluster,
>   * we limit us to a platform agnostic constant here for now.
>   * A followup commit may allow even bigger BIO sizes,
> diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
> index 08f193c341c5..1c679cb72785 100644
> --- a/drivers/staging/lustre/include/linux/lnet/types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/types.h
> @@ -514,7 +514,7 @@ typedef struct {
>  	/**
>  	 * Starting offset of the fragment within the page. Note that the
>  	 * end of the fragment must not pass the end of the page; i.e.,
> -	 * kiov_len + kiov_offset <= PAGE_CACHE_SIZE.
> +	 * kiov_len + kiov_offset <= PAGE_SIZE.
>  	 */
>  	unsigned int	 kiov_offset;
>  } lnet_kiov_t;
> diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
> index 5321ddec9580..e689ca1846e1 100644
> --- a/drivers/staging/lustre/lnet/selftest/selftest.h
> +++ b/drivers/staging/lustre/lnet/selftest/selftest.h
> @@ -390,8 +390,8 @@ typedef struct sfw_test_instance {
>  	} tsi_u;
>  } sfw_test_instance_t;
>  
> -/* XXX: trailing (PAGE_CACHE_SIZE % sizeof(lnet_process_id_t)) bytes at
> - * the end of pages are not used */
> +/* XXX: trailing (PAGE_SIZE % sizeof(lnet_process_id_t)) bytes at the end of
> + * pages are not used */
>  #define SFW_MAX_CONCUR	   LST_MAX_CONCUR
>  #define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(lnet_process_id_packed_t))
>  #define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
> diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
> index b5088b13a305..242bb1ef6245 100644
> --- a/drivers/staging/lustre/lustre/include/lu_object.h
> +++ b/drivers/staging/lustre/lustre/include/lu_object.h
> @@ -1118,7 +1118,7 @@ struct lu_context_key {
>  	{							 \
>  		type *value;				      \
>  								  \
> -		CLASSERT(PAGE_CACHE_SIZE >= sizeof (*value));       \
> +		CLASSERT(PAGE_SIZE >= sizeof (*value));       \
>  								  \
>  		value = kzalloc(sizeof(*value), GFP_NOFS);	\
>  		if (!value)				\
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> index 1e2ebe5cc998..5aae1d06a5fa 100644
> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> @@ -1022,10 +1022,10 @@ static inline int lu_dirent_size(struct lu_dirent *ent)
>   * MDS_READPAGE page size
>   *
>   * This is the directory page size packed in MDS_READPAGE RPC.
> - * It's different than PAGE_CACHE_SIZE because the client needs to
> + * It's different than PAGE_SIZE because the client needs to
>   * access the struct lu_dirpage header packed at the beginning of
>   * the "page" and without this there isn't any way to know find the
> - * lu_dirpage header is if client and server PAGE_CACHE_SIZE differ.
> + * lu_dirpage header is if client and server PAGE_SIZE differ.
>   */
>  #define LU_PAGE_SHIFT 12
>  #define LU_PAGE_SIZE  (1UL << LU_PAGE_SHIFT)
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index a5e9095fbf36..69586a522eb7 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -112,8 +112,8 @@
>  # if ((PTLRPC_MAX_BRW_PAGES & (PTLRPC_MAX_BRW_PAGES - 1)) != 0)
>  #  error "PTLRPC_MAX_BRW_PAGES isn't a power of two"
>  # endif
> -# if (PTLRPC_MAX_BRW_SIZE != (PTLRPC_MAX_BRW_PAGES * PAGE_CACHE_SIZE))
> -#  error "PTLRPC_MAX_BRW_SIZE isn't PTLRPC_MAX_BRW_PAGES * PAGE_CACHE_SIZE"
> +# if (PTLRPC_MAX_BRW_SIZE != (PTLRPC_MAX_BRW_PAGES * PAGE_SIZE))
> +#  error "PTLRPC_MAX_BRW_SIZE isn't PTLRPC_MAX_BRW_PAGES * PAGE_SIZE"
>  # endif
>  # if (PTLRPC_MAX_BRW_SIZE > LNET_MTU * PTLRPC_BULK_OPS_COUNT)
>  #  error "PTLRPC_MAX_BRW_SIZE too big"
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index f4167db65b5d..4264d97650ec 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -272,7 +272,7 @@ struct client_obd {
>  	int		 cl_grant_shrink_interval; /* seconds */
>  
>  	/* A chunk is an optimal size used by osc_extent to determine
> -	 * the extent size. A chunk is max(PAGE_CACHE_SIZE, OST block size)
> +	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
>  	 */
>  	int		  cl_chunkbits;
>  	int		  cl_chunk;
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index a7c02e07fd75..e4c82883e580 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -134,9 +134,8 @@
>   * a header lu_dirpage which describes the start/end hash, and whether this
>   * page is empty (contains no dir entry) or hash collide with next page.
>   * After client receives reply, several pages will be integrated into dir page
> - * in PAGE_CACHE_SIZE (if PAGE_CACHE_SIZE greater than LU_PAGE_SIZE), and the
> - * lu_dirpage for this integrated page will be adjusted. See
> - * lmv_adjust_dirpages().
> + * in PAGE_SIZE (if PAGE_SIZE greater than LU_PAGE_SIZE), and the lu_dirpage
> + * for this integrated page will be adjusted. See lmv_adjust_dirpages().
>   *
>   */
>  
> diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
> index 4c7250ab54e6..edab6c5b7e50 100644
> --- a/drivers/staging/lustre/lustre/llite/rw.c
> +++ b/drivers/staging/lustre/lustre/llite/rw.c
> @@ -521,7 +521,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
>   * striped over, rather than having a constant value for all files here.
>   */
>  
> -/* RAS_INCREASE_STEP should be (1UL << (inode->i_blkbits - PAGE_CACHE_SHIFT)).
> +/* RAS_INCREASE_STEP should be (1UL << (inode->i_blkbits - PAGE_SHIFT)).
>   * Temporarily set RAS_INCREASE_STEP to 1MB. After 4MB RPC is enabled
>   * by default, this should be adjusted corresponding with max_read_ahead_mb
>   * and max_read_ahead_per_file_mb otherwise the readahead budget can be used
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
> index 75d4df71cab8..85a835976174 100644
> --- a/drivers/staging/lustre/lustre/llite/vvp_io.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
> @@ -512,7 +512,7 @@ static int vvp_io_read_start(const struct lu_env *env,
>  		vio->cui_ra_window_set = 1;
>  		bead->lrr_start = cl_index(obj, pos);
>  		/*
> -		 * XXX: explicit PAGE_CACHE_SIZE
> +		 * XXX: explicit PAGE_SIZE
>  		 */
>  		bead->lrr_count = cl_index(obj, tot + PAGE_SIZE - 1);
>  		ll_ra_read_in(file, bead);
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index ce7e8b70dd44..9abb7c2b9231 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -2017,7 +2017,7 @@ static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
>   * |s|e|f|p|ent| 0 | ... | 0 |
>   * '-----------------   -----'
>   *
> - * However, on hosts where the native VM page size (PAGE_CACHE_SIZE) is
> + * However, on hosts where the native VM page size (PAGE_SIZE) is
>   * larger than LU_PAGE_SIZE, a single host page may contain multiple
>   * lu_dirpages. After reading the lu_dirpages from the MDS, the
>   * ldp_hash_end of the first lu_dirpage refers to the one immediately
> @@ -2048,7 +2048,7 @@ static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
>   * - Adjust the lde_reclen of the ending entry of each lu_dirpage to span
>   *   to the first entry of the next lu_dirpage.
>   */
> -#if PAGE_CACHE_SIZE > LU_PAGE_SIZE
> +#if PAGE_SIZE > LU_PAGE_SIZE
>  static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
>  {
>  	int i;
> @@ -2101,7 +2101,7 @@ static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
>  }
>  #else
>  #define lmv_adjust_dirpages(pages, ncfspgs, nlupgs) do {} while (0)
> -#endif	/* PAGE_CACHE_SIZE > LU_PAGE_SIZE */
> +#endif	/* PAGE_SIZE > LU_PAGE_SIZE */
>  
>  static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
>  			struct page **pages, struct ptlrpc_request **request)
> @@ -2110,7 +2110,7 @@ static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
>  	struct lmv_obd		*lmv = &obd->u.lmv;
>  	__u64			offset = op_data->op_offset;
>  	int			rc;
> -	int			ncfspgs; /* pages read in PAGE_CACHE_SIZE */
> +	int			ncfspgs; /* pages read in PAGE_SIZE */
>  	int			nlupgs; /* pages read in LU_PAGE_SIZE */
>  	struct lmv_tgt_desc	*tgt;
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
> index 4a2baaff3dc1..b41b65e2f021 100644
> --- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
> +++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
> @@ -47,7 +47,6 @@
>  #include "../../include/lustre/lustre_idl.h"
>  
>  #include <linux/fs.h>
> -#include <linux/pagemap.h> /* for PAGE_CACHE_SIZE */
>  
>  void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid)
>  {
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 4e0a357ed43d..5f25bf83dcfc 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -1456,7 +1456,7 @@ static void osc_unreserve_grant(struct client_obd *cli,
>   * used, we should return these grants to OST. There're two cases where grants
>   * can be lost:
>   * 1. truncate;
> - * 2. blocksize at OST is less than PAGE_CACHE_SIZE and a partial page was
> + * 2. blocksize at OST is less than PAGE_SIZE and a partial page was
>   *    written. In this case OST may use less chunks to serve this partial
>   *    write. OSTs don't actually know the page size on the client side. so
>   *    clients have to calculate lost grant by the blocksize on the OST.
> diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
> index 748df9040e41..e17b46805aa1 100644
> --- a/fs/btrfs/check-integrity.c
> +++ b/fs/btrfs/check-integrity.c
> @@ -3037,13 +3037,13 @@ int btrfsic_mount(struct btrfs_root *root,
>  
>  	if (root->nodesize & ((u64)PAGE_SIZE - 1)) {
>  		printk(KERN_INFO
> -		       "btrfsic: cannot handle nodesize %d not being a multiple of PAGE_CACHE_SIZE %ld!\n",
> +		       "btrfsic: cannot handle nodesize %d not being a multiple of PAGE_SIZE %ld!\n",
>  		       root->nodesize, PAGE_SIZE);
>  		return -1;
>  	}
>  	if (root->sectorsize & ((u64)PAGE_SIZE - 1)) {
>  		printk(KERN_INFO
> -		       "btrfsic: cannot handle sectorsize %d not being a multiple of PAGE_CACHE_SIZE %ld!\n",
> +		       "btrfsic: cannot handle sectorsize %d not being a multiple of PAGE_SIZE %ld!\n",
>  		       root->sectorsize, PAGE_SIZE);
>  		return -1;
>  	}
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index ce50203e5855..cb4d28960f1b 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -3268,13 +3268,11 @@ static noinline_for_stack int writepage_delalloc(struct inode *inode,
>  			goto done;
>  		}
>  		/*
> -		 * delalloc_end is already one less than the total
> -		 * length, so we don't subtract one from
> -		 * PAGE_CACHE_SIZE
> +		 * delalloc_end is already one less than the total length, so
> +		 * we don't subtract one from PAGE_SIZE
>  		 */
>  		delalloc_to_write += (delalloc_end - delalloc_start +
> -				      PAGE_SIZE) >>
> -				      PAGE_SHIFT;
> +				      PAGE_SIZE) >> PAGE_SHIFT;
>  		delalloc_start = delalloc_end + 1;
>  	}
>  	if (wbc->nr_to_write < delalloc_to_write) {
> diff --git a/fs/btrfs/struct-funcs.c b/fs/btrfs/struct-funcs.c
> index b976597b0721..e05619f241be 100644
> --- a/fs/btrfs/struct-funcs.c
> +++ b/fs/btrfs/struct-funcs.c
> @@ -66,7 +66,7 @@ u##bits btrfs_get_token_##bits(struct extent_buffer *eb, void *ptr,	\
>  									\
>  	if (token && token->kaddr && token->offset <= offset &&		\
>  	    token->eb == eb &&						\
> -	   (token->offset + PAGE_CACHE_SIZE >= offset + size)) {	\
> +	   (token->offset + PAGE_SIZE >= offset + size)) {	\
>  		kaddr = token->kaddr;					\
>  		p = kaddr + part_offset - token->offset;		\
>  		res = get_unaligned_le##bits(p + off);			\
> @@ -104,7 +104,7 @@ void btrfs_set_token_##bits(struct extent_buffer *eb,			\
>  									\
>  	if (token && token->kaddr && token->offset <= offset &&		\
>  	    token->eb == eb &&						\
> -	   (token->offset + PAGE_CACHE_SIZE >= offset + size)) {	\
> +	   (token->offset + PAGE_SIZE >= offset + size)) {	\
>  		kaddr = token->kaddr;					\
>  		p = kaddr + part_offset - token->offset;		\
>  		put_unaligned_le##bits(val, p + off);			\
> diff --git a/fs/btrfs/tests/extent-io-tests.c b/fs/btrfs/tests/extent-io-tests.c
> index ac3a06d28531..70948b13bc81 100644
> --- a/fs/btrfs/tests/extent-io-tests.c
> +++ b/fs/btrfs/tests/extent-io-tests.c
> @@ -239,7 +239,7 @@ static int test_find_delalloc(void)
>  	end = 0;
>  	/*
>  	 * Currently if we fail to find dirty pages in the delalloc range we
> -	 * will adjust max_bytes down to PAGE_CACHE_SIZE and then re-search.  If
> +	 * will adjust max_bytes down to PAGE_SIZE and then re-search.  If
>  	 * this changes at any point in the future we will need to fix this
>  	 * tests expected behavior.
>  	 */
> diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
> index d21da9f05bae..f2cc0b3d1af7 100644
> --- a/fs/cifs/cifsglob.h
> +++ b/fs/cifs/cifsglob.h
> @@ -714,7 +714,7 @@ compare_mid(__u16 mid, const struct smb_hdr *smb)
>   *
>   * Note that this might make for "interesting" allocation problems during
>   * writeback however as we have to allocate an array of pointers for the
> - * pages. A 16M write means ~32kb page array with PAGE_CACHE_SIZE == 4096.
> + * pages. A 16M write means ~32kb page array with PAGE_SIZE == 4096.
>   *
>   * For reads, there is a similar problem as we need to allocate an array
>   * of kvecs to handle the receive, though that should only need to be done
> @@ -733,7 +733,7 @@ compare_mid(__u16 mid, const struct smb_hdr *smb)
>  
>  /*
>   * The default wsize is 1M. find_get_pages seems to return a maximum of 256
> - * pages in a single call. With PAGE_CACHE_SIZE == 4k, this means we can fill
> + * pages in a single call. With PAGE_SIZE == 4k, this means we can fill
>   * a single wsize request with a single call.
>   */
>  #define CIFS_DEFAULT_IOSIZE (1024 * 1024)
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index 5ce540dc6996..c03d0744648b 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -1902,7 +1902,7 @@ wdata_alloc_and_fillpages(pgoff_t tofind, struct address_space *mapping,
>  	 * find_get_pages_tag seems to return a max of 256 on each
>  	 * iteration, so we must call it several times in order to
>  	 * fill the array or the wsize is effectively limited to
> -	 * 256 * PAGE_CACHE_SIZE.
> +	 * 256 * PAGE_SIZE.
>  	 */
>  	*found_pages = 0;
>  	pages = wdata->pages;
> diff --git a/fs/cramfs/README b/fs/cramfs/README
> index 445d1c2d7646..9d4e7ea311f4 100644
> --- a/fs/cramfs/README
> +++ b/fs/cramfs/README
> @@ -86,26 +86,26 @@ Block Size
>  
>  (Block size in cramfs refers to the size of input data that is
>  compressed at a time.  It's intended to be somewhere around
> -PAGE_CACHE_SIZE for cramfs_readpage's convenience.)
> +PAGE_SIZE for cramfs_readpage's convenience.)
>  
>  The superblock ought to indicate the block size that the fs was
>  written for, since comments in <linux/pagemap.h> indicate that
> -PAGE_CACHE_SIZE may grow in future (if I interpret the comment
> +PAGE_SIZE may grow in future (if I interpret the comment
>  correctly).
>  
> -Currently, mkcramfs #define's PAGE_CACHE_SIZE as 4096 and uses that
> -for blksize, whereas Linux-2.3.39 uses its PAGE_CACHE_SIZE, which in
> +Currently, mkcramfs #define's PAGE_SIZE as 4096 and uses that
> +for blksize, whereas Linux-2.3.39 uses its PAGE_SIZE, which in
>  turn is defined as PAGE_SIZE (which can be as large as 32KB on arm).
>  This discrepancy is a bug, though it's not clear which should be
>  changed.
>  
> -One option is to change mkcramfs to take its PAGE_CACHE_SIZE from
> +One option is to change mkcramfs to take its PAGE_SIZE from
>  <asm/page.h>.  Personally I don't like this option, but it does
>  require the least amount of change: just change `#define
> -PAGE_CACHE_SIZE (4096)' to `#include <asm/page.h>'.  The disadvantage
> +PAGE_SIZE (4096)' to `#include <asm/page.h>'.  The disadvantage
>  is that the generated cramfs cannot always be shared between different
>  kernels, not even necessarily kernels of the same architecture if
> -PAGE_CACHE_SIZE is subject to change between kernel versions
> +PAGE_SIZE is subject to change between kernel versions
>  (currently possible with arm and ia64).
>  
>  The remaining options try to make cramfs more sharable.
> @@ -126,22 +126,22 @@ size.  The options are:
>    1. Always 4096 bytes.
>  
>    2. Writer chooses blocksize; kernel adapts but rejects blocksize >
> -     PAGE_CACHE_SIZE.
> +     PAGE_SIZE.
>  
>    3. Writer chooses blocksize; kernel adapts even to blocksize >
> -     PAGE_CACHE_SIZE.
> +     PAGE_SIZE.
>  
>  It's easy enough to change the kernel to use a smaller value than
> -PAGE_CACHE_SIZE: just make cramfs_readpage read multiple blocks.
> +PAGE_SIZE: just make cramfs_readpage read multiple blocks.
>  
> -The cost of option 1 is that kernels with a larger PAGE_CACHE_SIZE
> +The cost of option 1 is that kernels with a larger PAGE_SIZE
>  value don't get as good compression as they can.
>  
>  The cost of option 2 relative to option 1 is that the code uses
>  variables instead of #define'd constants.  The gain is that people
> -with kernels having larger PAGE_CACHE_SIZE can make use of that if
> +with kernels having larger PAGE_SIZE can make use of that if
>  they don't mind their cramfs being inaccessible to kernels with
> -smaller PAGE_CACHE_SIZE values.
> +smaller PAGE_SIZE values.
>  
>  Option 3 is easy to implement if we don't mind being CPU-inefficient:
>  e.g. get readpage to decompress to a buffer of size MAX_BLKSIZE (which
> diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
> index 2096654dd26d..3a32ddf98095 100644
> --- a/fs/cramfs/inode.c
> +++ b/fs/cramfs/inode.c
> @@ -137,7 +137,7 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
>   * page cache and dentry tree anyway..
>   *
>   * This also acts as a way to guarantee contiguous areas of up to
> - * BLKS_PER_BUF*PAGE_CACHE_SIZE, so that the caller doesn't need to
> + * BLKS_PER_BUF*PAGE_SIZE, so that the caller doesn't need to
>   * worry about end-of-buffer issues even when decompressing a full
>   * page cache.
>   */
> diff --git a/fs/dax.c b/fs/dax.c
> index 9df3f192d625..1144c55561f5 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1089,7 +1089,7 @@ EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
>   * you are truncating a file, the helper function dax_truncate_page() may be
>   * more convenient.
>   *
> - * We work in terms of PAGE_CACHE_SIZE here for commonality with
> + * We work in terms of PAGE_SIZE here for commonality with
>   * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
>   * took care of disposing of the unnecessary blocks.  Even if the filesystem
>   * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
> @@ -1141,7 +1141,7 @@ EXPORT_SYMBOL_GPL(dax_zero_page_range);
>   * Similar to block_truncate_page(), this function can be called by a
>   * filesystem when it is truncating a DAX file to handle the partial page.
>   *
> - * We work in terms of PAGE_CACHE_SIZE here for commonality with
> + * We work in terms of PAGE_SIZE here for commonality with
>   * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
>   * took care of disposing of the unnecessary blocks.  Even if the filesystem
>   * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
> diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> index 2a988f3a0cdb..224b49e71aa4 100644
> --- a/fs/ecryptfs/inode.c
> +++ b/fs/ecryptfs/inode.c
> @@ -763,8 +763,8 @@ static int truncate_upper(struct dentry *dentry, struct iattr *ia,
>  	} else { /* ia->ia_size < i_size_read(inode) */
>  		/* We're chopping off all the pages down to the page
>  		 * in which ia->ia_size is located. Fill in the end of
> -		 * that page from (ia->ia_size & ~PAGE_CACHE_MASK) to
> -		 * PAGE_CACHE_SIZE with zeros. */
> +		 * that page from (ia->ia_size & ~PAGE_MASK) to
> +		 * PAGE_SIZE with zeros. */
>  		size_t num_zeros = (PAGE_SIZE
>  				    - (ia->ia_size & ~PAGE_MASK));
>  
> diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
> index 1b45694de316..7ff6fcfa685d 100644
> --- a/fs/ext2/dir.c
> +++ b/fs/ext2/dir.c
> @@ -37,7 +37,7 @@ static inline unsigned ext2_rec_len_from_disk(__le16 dlen)
>  {
>  	unsigned len = le16_to_cpu(dlen);
>  
> -#if (PAGE_CACHE_SIZE >= 65536)
> +#if (PAGE_SIZE >= 65536)
>  	if (len == EXT2_MAX_REC_LEN)
>  		return 1 << 16;
>  #endif
> @@ -46,7 +46,7 @@ static inline unsigned ext2_rec_len_from_disk(__le16 dlen)
>  
>  static inline __le16 ext2_rec_len_to_disk(unsigned len)
>  {
> -#if (PAGE_CACHE_SIZE >= 65536)
> +#if (PAGE_SIZE >= 65536)
>  	if (len == (1 << 16))
>  		return cpu_to_le16(EXT2_MAX_REC_LEN);
>  	else
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 393689dfa1af..d96ec1dd22a9 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -1970,7 +1970,7 @@ ext4_rec_len_from_disk(__le16 dlen, unsigned blocksize)
>  {
>  	unsigned len = le16_to_cpu(dlen);
>  
> -#if (PAGE_CACHE_SIZE >= 65536)
> +#if (PAGE_SIZE >= 65536)
>  	if (len == EXT4_MAX_REC_LEN || len == 0)
>  		return blocksize;
>  	return (len & 65532) | ((len & 3) << 16);
> @@ -1983,7 +1983,7 @@ static inline __le16 ext4_rec_len_to_disk(unsigned len, unsigned blocksize)
>  {
>  	if ((len > blocksize) || (blocksize > (1 << 18)) || (len & 3))
>  		BUG();
> -#if (PAGE_CACHE_SIZE >= 65536)
> +#if (PAGE_SIZE >= 65536)
>  	if (len < 65536)
>  		return cpu_to_le16(len);
>  	if (len == blocksize) {
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 9cfce0489339..58ec44be2f42 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -4884,7 +4884,7 @@ static void ext4_wait_for_tail_page_commit(struct inode *inode)
>  	offset = inode->i_size & (PAGE_SIZE - 1);
>  	/*
>  	 * All buffers in the last page remain valid? Then there's nothing to
> -	 * do. We do the check mainly to optimize the common PAGE_CACHE_SIZE ==
> +	 * do. We do the check mainly to optimize the common PAGE_SIZE ==
>  	 * blocksize case
>  	 */
>  	if (offset > PAGE_SIZE - (1 << inode->i_blkbits))
> diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
> index c12174711ce2..eeeade76012e 100644
> --- a/fs/ext4/mballoc.c
> +++ b/fs/ext4/mballoc.c
> @@ -119,7 +119,7 @@ MODULE_PARM_DESC(mballoc_debug, "Debugging level for ext4's mballoc");
>   *
>   *
>   * one block each for bitmap and buddy information.  So for each group we
> - * take up 2 blocks. A page can contain blocks_per_page (PAGE_CACHE_SIZE /
> + * take up 2 blocks. A page can contain blocks_per_page (PAGE_SIZE /
>   * blocksize) blocks.  So it can have information regarding groups_per_page
>   * which is blocks_per_page/2
>   *
> @@ -807,7 +807,7 @@ static void mb_regenerate_buddy(struct ext4_buddy *e4b)
>   *
>   * one block each for bitmap and buddy information.
>   * So for each group we take up 2 blocks. A page can
> - * contain blocks_per_page (PAGE_CACHE_SIZE / blocksize)  blocks.
> + * contain blocks_per_page (PAGE_SIZE / blocksize)  blocks.
>   * So it can have information regarding groups_per_page which
>   * is blocks_per_page/2
>   *
> diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
> index ea27aa1a778c..f24e7299e1c8 100644
> --- a/fs/ext4/readpage.c
> +++ b/fs/ext4/readpage.c
> @@ -23,7 +23,7 @@
>   *
>   * then this code just gives up and calls the buffer_head-based read function.
>   * It does handle a page which has holes at the end - that is a common case:
> - * the end-of-file on blocksize < PAGE_CACHE_SIZE setups.
> + * the end-of-file on blocksize < PAGE_SIZE setups.
>   *
>   */
>  
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index afb7c7f05de5..4ea71eba40a5 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -237,7 +237,7 @@ hugetlbfs_read_actor(struct page *page, unsigned long offset,
>  /*
>   * Support for read() - Find the page attached to f_mapping and copy out the
>   * data. Its *very* similar to do_generic_mapping_read(), we can't use that
> - * since it has PAGE_CACHE_SIZE assumptions.
> + * since it has PAGE_SIZE assumptions.
>   */
>  static ssize_t hugetlbfs_read_iter(struct kiocb *iocb, struct iov_iter *to)
>  {
> diff --git a/fs/mpage.c b/fs/mpage.c
> index 243c9f68f696..1a4076ba3e04 100644
> --- a/fs/mpage.c
> +++ b/fs/mpage.c
> @@ -331,7 +331,7 @@ confused:
>   *
>   * then this code just gives up and calls the buffer_head-based read function.
>   * It does handle a page which has holes at the end - that is a common case:
> - * the end-of-file on blocksize < PAGE_CACHE_SIZE setups.
> + * the end-of-file on blocksize < PAGE_SIZE setups.
>   *
>   * BH_Boundary explanation:
>   *
> diff --git a/fs/ntfs/aops.c b/fs/ntfs/aops.c
> index a474e7ef92ea..97768a1379f2 100644
> --- a/fs/ntfs/aops.c
> +++ b/fs/ntfs/aops.c
> @@ -674,7 +674,7 @@ static int ntfs_write_block(struct page *page, struct writeback_control *wbc)
>  				// in the inode.
>  				// Again, for each page do:
>  				//	__set_page_dirty_buffers();
> -				// page_cache_release()
> +				// put_page()
>  				// We don't need to wait on the writes.
>  				// Update iblock.
>  			}
> diff --git a/fs/ntfs/aops.h b/fs/ntfs/aops.h
> index 37cd7e45dcbc..820d6eabf60f 100644
> --- a/fs/ntfs/aops.h
> +++ b/fs/ntfs/aops.h
> @@ -49,7 +49,7 @@ static inline void ntfs_unmap_page(struct page *page)
>   * @index:	index into the page cache for @mapping of the page to map
>   *
>   * Read a page from the page cache of the address space @mapping at position
> - * @index, where @index is in units of PAGE_CACHE_SIZE, and not in bytes.
> + * @index, where @index is in units of PAGE_SIZE, and not in bytes.
>   *
>   * If the page is not in memory it is loaded from disk first using the readpage
>   * method defined in the address space operations of @mapping and the page is
> diff --git a/fs/ntfs/compress.c b/fs/ntfs/compress.c
> index b6074a56661b..f2b5e746f49b 100644
> --- a/fs/ntfs/compress.c
> +++ b/fs/ntfs/compress.c
> @@ -105,10 +105,6 @@ static void zero_partial_compressed_page(struct page *page,
>  
>  	ntfs_debug("Zeroing page region outside initialized size.");
>  	if (((s64)page->index << PAGE_SHIFT) >= initialized_size) {
> -		/*
> -		 * FIXME: Using clear_page() will become wrong when we get
> -		 * PAGE_CACHE_SIZE != PAGE_SIZE but for now there is no problem.
> -		 */
>  		clear_page(kp);
>  		return;
>  	}
> @@ -160,7 +156,7 @@ static inline void handle_bounds_compressed_page(struct page *page,
>   * @xpage_done indicates whether the target page (@dest_pages[@xpage]) was
>   * completed during the decompression of the compression block (@cb_start).
>   *
> - * Warning: This function *REQUIRES* PAGE_CACHE_SIZE >= 4096 or it will blow up
> + * Warning: This function *REQUIRES* PAGE_SIZE >= 4096 or it will blow up
>   * unpredicatbly! You have been warned!
>   *
>   * Note to hackers: This function may not sleep until it has finished accessing
> @@ -462,7 +458,7 @@ return_overflow:
>   * have been written to so that we would lose data if we were to just overwrite
>   * them with the out-of-date uncompressed data.
>   *
> - * FIXME: For PAGE_CACHE_SIZE > cb_size we are not doing the Right Thing(TM) at
> + * FIXME: For PAGE_SIZE > cb_size we are not doing the Right Thing(TM) at
>   * the end of the file I think. We need to detect this case and zero the out
>   * of bounds remainder of the page in question and mark it as handled. At the
>   * moment we would just return -EIO on such a page. This bug will only become
> @@ -470,7 +466,7 @@ return_overflow:
>   * clusters so is probably not going to be seen by anyone. Still this should
>   * be fixed. (AIA)
>   *
> - * FIXME: Again for PAGE_CACHE_SIZE > cb_size we are screwing up both in
> + * FIXME: Again for PAGE_SIZE > cb_size we are screwing up both in
>   * handling sparse and compressed cbs. (AIA)
>   *
>   * FIXME: At the moment we don't do any zeroing out in the case that
> @@ -497,12 +493,12 @@ int ntfs_read_compressed_block(struct page *page)
>  	u64 cb_size_mask = cb_size - 1UL;
>  	VCN vcn;
>  	LCN lcn;
> -	/* The first wanted vcn (minimum alignment is PAGE_CACHE_SIZE). */
> +	/* The first wanted vcn (minimum alignment is PAGE_SIZE). */
>  	VCN start_vcn = (((s64)index << PAGE_SHIFT) & ~cb_size_mask) >>
>  			vol->cluster_size_bits;
>  	/*
>  	 * The first vcn after the last wanted vcn (minimum alignment is again
> -	 * PAGE_CACHE_SIZE.
> +	 * PAGE_SIZE.
>  	 */
>  	VCN end_vcn = ((((s64)(index + 1UL) << PAGE_SHIFT) + cb_size - 1)
>  			& ~cb_size_mask) >> vol->cluster_size_bits;
> @@ -753,11 +749,6 @@ lock_retry_remap:
>  		for (; cur_page < cb_max_page; cur_page++) {
>  			page = pages[cur_page];
>  			if (page) {
> -				/*
> -				 * FIXME: Using clear_page() will become wrong
> -				 * when we get PAGE_CACHE_SIZE != PAGE_SIZE but
> -				 * for now there is no problem.
> -				 */
>  				if (likely(!cur_ofs))
>  					clear_page(page_address(page));
>  				else
> @@ -807,7 +798,7 @@ lock_retry_remap:
>  		 * synchronous io for the majority of pages.
>  		 * Or if we choose not to do the read-ahead/-behind stuff, we
>  		 * could just return block_read_full_page(pages[xpage]) as long
> -		 * as PAGE_CACHE_SIZE <= cb_size.
> +		 * as PAGE_SIZE <= cb_size.
>  		 */
>  		if (cb_max_ofs)
>  			cb_max_page--;
> diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
> index 3cdce162592d..a18613579001 100644
> --- a/fs/ntfs/dir.c
> +++ b/fs/ntfs/dir.c
> @@ -315,7 +315,7 @@ found_it:
>  descend_into_child_node:
>  	/*
>  	 * Convert vcn to index into the index allocation attribute in units
> -	 * of PAGE_CACHE_SIZE and map the page cache page, reading it from
> +	 * of PAGE_SIZE and map the page cache page, reading it from
>  	 * disk if necessary.
>  	 */
>  	page = ntfs_map_page(ia_mapping, vcn <<
> @@ -793,11 +793,11 @@ found_it:
>  descend_into_child_node:
>  	/*
>  	 * Convert vcn to index into the index allocation attribute in units
> -	 * of PAGE_CACHE_SIZE and map the page cache page, reading it from
> +	 * of PAGE_SIZE and map the page cache page, reading it from
>  	 * disk if necessary.
>  	 */
>  	page = ntfs_map_page(ia_mapping, vcn <<
> -			dir_ni->itype.index.vcn_size_bits >> PAGE_CACHE_SHIFT);
> +			dir_ni->itype.index.vcn_size_bits >> PAGE_SHIFT);
>  	if (IS_ERR(page)) {
>  		ntfs_error(sb, "Failed to map directory index page, error %ld.",
>  				-PTR_ERR(page));
> @@ -809,9 +809,9 @@ descend_into_child_node:
>  fast_descend_into_child_node:
>  	/* Get to the index allocation block. */
>  	ia = (INDEX_ALLOCATION*)(kaddr + ((vcn <<
> -			dir_ni->itype.index.vcn_size_bits) & ~PAGE_CACHE_MASK));
> +			dir_ni->itype.index.vcn_size_bits) & ~PAGE_MASK));
>  	/* Bounds checks. */
> -	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE) {
> +	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE) {
>  		ntfs_error(sb, "Out of bounds check failed. Corrupt directory "
>  				"inode 0x%lx or driver bug.", dir_ni->mft_no);
>  		goto unm_err_out;
> @@ -844,7 +844,7 @@ fast_descend_into_child_node:
>  		goto unm_err_out;
>  	}
>  	index_end = (u8*)ia + dir_ni->itype.index.block_size;
> -	if (index_end > kaddr + PAGE_CACHE_SIZE) {
> +	if (index_end > kaddr + PAGE_SIZE) {
>  		ntfs_error(sb, "Index buffer (VCN 0x%llx) of directory inode "
>  				"0x%lx crosses page boundary. Impossible! "
>  				"Cannot access! This is probably a bug in the "
> @@ -968,9 +968,9 @@ found_it2:
>  			/* If vcn is in the same page cache page as old_vcn we
>  			 * recycle the mapped page. */
>  			if (old_vcn << vol->cluster_size_bits >>
> -					PAGE_CACHE_SHIFT == vcn <<
> +					PAGE_SHIFT == vcn <<
>  					vol->cluster_size_bits >>
> -					PAGE_CACHE_SHIFT)
> +					PAGE_SHIFT)
>  				goto fast_descend_into_child_node;
>  			unlock_page(page);
>  			ntfs_unmap_page(page);
> diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
> index 2dae60857544..91117ada8528 100644
> --- a/fs/ntfs/file.c
> +++ b/fs/ntfs/file.c
> @@ -573,7 +573,7 @@ static inline int ntfs_submit_bh_for_read(struct buffer_head *bh)
>   * only partially being written to.
>   *
>   * If @nr_pages is greater than one, we are guaranteed that the cluster size is
> - * greater than PAGE_CACHE_SIZE, that all pages in @pages are entirely inside
> + * greater than PAGE_SIZE, that all pages in @pages are entirely inside
>   * the same cluster and that they are the entirety of that cluster, and that
>   * the cluster is sparse, i.e. we need to allocate a cluster to fill the hole.
>   *
> diff --git a/fs/ntfs/index.c b/fs/ntfs/index.c
> index 02a83a46ead2..0d645f357930 100644
> --- a/fs/ntfs/index.c
> +++ b/fs/ntfs/index.c
> @@ -272,7 +272,7 @@ done:
>  descend_into_child_node:
>  	/*
>  	 * Convert vcn to index into the index allocation attribute in units
> -	 * of PAGE_CACHE_SIZE and map the page cache page, reading it from
> +	 * of PAGE_SIZE and map the page cache page, reading it from
>  	 * disk if necessary.
>  	 */
>  	page = ntfs_map_page(ia_mapping, vcn <<
> diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
> index 3eda6d4bcc65..f40972d6df90 100644
> --- a/fs/ntfs/inode.c
> +++ b/fs/ntfs/inode.c
> @@ -870,7 +870,7 @@ skip_attr_list_load:
>  		}
>  		if (ni->itype.index.block_size > PAGE_SIZE) {
>  			ntfs_error(vi->i_sb, "Index block size (%u) > "
> -					"PAGE_CACHE_SIZE (%ld) is not "
> +					"PAGE_SIZE (%ld) is not "
>  					"supported.  Sorry.",
>  					ni->itype.index.block_size,
>  					PAGE_SIZE);
> @@ -1586,7 +1586,7 @@ static int ntfs_read_locked_index_inode(struct inode *base_vi, struct inode *vi)
>  		goto unm_err_out;
>  	}
>  	if (ni->itype.index.block_size > PAGE_SIZE) {
> -		ntfs_error(vi->i_sb, "Index block size (%u) > PAGE_CACHE_SIZE "
> +		ntfs_error(vi->i_sb, "Index block size (%u) > PAGE_SIZE "
>  				"(%ld) is not supported.  Sorry.",
>  				ni->itype.index.block_size, PAGE_SIZE);
>  		err = -EOPNOTSUPP;
> diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
> index ab2b0930054e..ecb49870a680 100644
> --- a/fs/ntfs/super.c
> +++ b/fs/ntfs/super.c
> @@ -823,12 +823,12 @@ static bool parse_ntfs_boot_sector(ntfs_volume *vol, const NTFS_BOOT_SECTOR *b)
>  	ntfs_debug("vol->mft_record_size_bits = %i (0x%x)",
>  			vol->mft_record_size_bits, vol->mft_record_size_bits);
>  	/*
> -	 * We cannot support mft record sizes above the PAGE_CACHE_SIZE since
> +	 * We cannot support mft record sizes above the PAGE_SIZE since
>  	 * we store $MFT/$DATA, the table of mft records in the page cache.
>  	 */
>  	if (vol->mft_record_size > PAGE_SIZE) {
>  		ntfs_error(vol->sb, "Mft record size (%i) exceeds the "
> -				"PAGE_CACHE_SIZE on your system (%lu).  "
> +				"PAGE_SIZE on your system (%lu).  "
>  				"This is not supported.  Sorry.",
>  				vol->mft_record_size, PAGE_SIZE);
>  		return false;
> @@ -2471,12 +2471,12 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
>  	down_read(&vol->lcnbmp_lock);
>  	/*
>  	 * Convert the number of bits into bytes rounded up, then convert into
> -	 * multiples of PAGE_CACHE_SIZE, rounding up so that if we have one
> +	 * multiples of PAGE_SIZE, rounding up so that if we have one
>  	 * full and one partial page max_index = 2.
>  	 */
>  	max_index = (((vol->nr_clusters + 7) >> 3) + PAGE_SIZE - 1) >>
>  			PAGE_SHIFT;
> -	/* Use multiples of 4 bytes, thus max_size is PAGE_CACHE_SIZE / 4. */
> +	/* Use multiples of 4 bytes, thus max_size is PAGE_SIZE / 4. */
>  	ntfs_debug("Reading $Bitmap, max_index = 0x%lx, max_size = 0x%lx.",
>  			max_index, PAGE_SIZE / 4);
>  	for (index = 0; index < max_index; index++) {
> @@ -2547,7 +2547,7 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
>  	pgoff_t index;
>  
>  	ntfs_debug("Entering.");
> -	/* Use multiples of 4 bytes, thus max_size is PAGE_CACHE_SIZE / 4. */
> +	/* Use multiples of 4 bytes, thus max_size is PAGE_SIZE / 4. */
>  	ntfs_debug("Reading $MFT/$BITMAP, max_index = 0x%lx, max_size = "
>  			"0x%lx.", max_index, PAGE_SIZE / 4);
>  	for (index = 0; index < max_index; index++) {
> @@ -2639,7 +2639,7 @@ static int ntfs_statfs(struct dentry *dentry, struct kstatfs *sfs)
>  	size = i_size_read(vol->mft_ino) >> vol->mft_record_size_bits;
>  	/*
>  	 * Convert the maximum number of set bits into bytes rounded up, then
> -	 * convert into multiples of PAGE_CACHE_SIZE, rounding up so that if we
> +	 * convert into multiples of PAGE_SIZE, rounding up so that if we
>  	 * have one full and one partial page max_index = 2.
>  	 */
>  	max_index = ((((mft_ni->initialized_size >> vol->mft_record_size_bits)
> @@ -2765,7 +2765,7 @@ static int ntfs_fill_super(struct super_block *sb, void *opt, const int silent)
>  	if (!parse_options(vol, (char*)opt))
>  		goto err_out_now;
>  
> -	/* We support sector sizes up to the PAGE_CACHE_SIZE. */
> +	/* We support sector sizes up to the PAGE_SIZE. */
>  	if (bdev_logical_block_size(sb->s_bdev) > PAGE_SIZE) {
>  		if (!silent)
>  			ntfs_error(sb, "Device has unsupported sector size "
> diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
> index 29b843028b93..af9298370d98 100644
> --- a/fs/ocfs2/aops.c
> +++ b/fs/ocfs2/aops.c
> @@ -1188,7 +1188,7 @@ next_bh:
>  	return ret;
>  }
>  
> -#if (PAGE_CACHE_SIZE >= OCFS2_MAX_CLUSTERSIZE)
> +#if (PAGE_SIZE >= OCFS2_MAX_CLUSTERSIZE)
>  #define OCFS2_MAX_CTXT_PAGES	1
>  #else
>  #define OCFS2_MAX_CTXT_PAGES	(OCFS2_MAX_CLUSTERSIZE / PAGE_SIZE)
> diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
> index 881242c3a8d2..744d5d90c363 100644
> --- a/fs/ocfs2/refcounttree.c
> +++ b/fs/ocfs2/refcounttree.c
> @@ -2956,7 +2956,7 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
>  		}
>  
>  		/*
> -		 * In case PAGE_CACHE_SIZE <= CLUSTER_SIZE, This page
> +		 * In case PAGE_SIZE <= CLUSTER_SIZE, This page
>  		 * can't be dirtied before we CoW it out.
>  		 */
>  		if (PAGE_SIZE <= OCFS2_SB(sb)->s_clustersize)
> diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
> index 8c6487238bb3..2ace90e981f0 100644
> --- a/fs/reiserfs/journal.c
> +++ b/fs/reiserfs/journal.c
> @@ -599,7 +599,7 @@ static int journal_list_still_alive(struct super_block *s,
>   * This does a check to see if the buffer belongs to one of these
>   * lost pages before doing the final put_bh.  If page->mapping was
>   * null, it tries to free buffers on the page, which should make the
> - * final page_cache_release drop the page from the lru.
> + * final put_page drop the page from the lru.
>   */
>  static void release_buffer_page(struct buffer_head *bh)
>  {
> diff --git a/fs/squashfs/cache.c b/fs/squashfs/cache.c
> index 27e501af0e8b..23813c078cc9 100644
> --- a/fs/squashfs/cache.c
> +++ b/fs/squashfs/cache.c
> @@ -30,7 +30,7 @@
>   * access the metadata and fragment caches.
>   *
>   * To avoid out of memory and fragmentation issues with vmalloc the cache
> - * uses sequences of kmalloced PAGE_CACHE_SIZE buffers.
> + * uses sequences of kmalloced PAGE_SIZE buffers.
>   *
>   * It should be noted that the cache is not used for file datablocks, these
>   * are decompressed and cached in the page-cache in the normal way.  The
> @@ -231,7 +231,7 @@ void squashfs_cache_delete(struct squashfs_cache *cache)
>  /*
>   * Initialise cache allocating the specified number of entries, each of
>   * size block_size.  To avoid vmalloc fragmentation issues each entry
> - * is allocated as a sequence of kmalloced PAGE_CACHE_SIZE buffers.
> + * is allocated as a sequence of kmalloced PAGE_SIZE buffers.
>   */
>  struct squashfs_cache *squashfs_cache_init(char *name, int entries,
>  	int block_size)
> diff --git a/fs/squashfs/file.c b/fs/squashfs/file.c
> index 437de9e89221..13d80947bf9e 100644
> --- a/fs/squashfs/file.c
> +++ b/fs/squashfs/file.c
> @@ -382,7 +382,7 @@ void squashfs_copy_cache(struct page *page, struct squashfs_cache_entry *buffer,
>  
>  	/*
>  	 * Loop copying datablock into pages.  As the datablock likely covers
> -	 * many PAGE_CACHE_SIZE pages (default block size is 128 KiB) explicitly
> +	 * many PAGE_SIZE pages (default block size is 128 KiB) explicitly
>  	 * grab the pages from the page cache, except for the page that we've
>  	 * been called to fill.
>  	 */
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index 1a9c6640e604..446753d8ac34 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -554,7 +554,7 @@ static int ubifs_write_end(struct file *file, struct address_space *mapping,
>  		 * VFS copied less data to the page that it intended and
>  		 * declared in its '->write_begin()' call via the @len
>  		 * argument. If the page was not up-to-date, and @len was
> -		 * @PAGE_CACHE_SIZE, the 'ubifs_write_begin()' function did
> +		 * @PAGE_SIZE, the 'ubifs_write_begin()' function did
>  		 * not load it from the media (for optimization reasons). This
>  		 * means that part of the page contains garbage. So read the
>  		 * page now.
> diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
> index 20daea9aa657..e98c24ee25a1 100644
> --- a/fs/ubifs/super.c
> +++ b/fs/ubifs/super.c
> @@ -2237,7 +2237,7 @@ static int __init ubifs_init(void)
>  	BUILD_BUG_ON(UBIFS_COMPR_TYPES_CNT > 4);
>  
>  	/*
> -	 * We require that PAGE_CACHE_SIZE is greater-than-or-equal-to
> +	 * We require that PAGE_SIZE is greater-than-or-equal-to
>  	 * UBIFS_BLOCK_SIZE. It is assumed that both are powers of 2.
>  	 */
>  	if (PAGE_SIZE < UBIFS_BLOCK_SIZE) {
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 27fe4cc80d4a..d12dfcfd0cc8 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -719,8 +719,8 @@ xfs_convert_page(
>  	 * Derivation:
>  	 *
>  	 * End offset is the highest offset that this page should represent.
> -	 * If we are on the last page, (end_offset & (PAGE_CACHE_SIZE - 1))
> -	 * will evaluate non-zero and be less than PAGE_CACHE_SIZE and
> +	 * If we are on the last page, (end_offset & (PAGE_SIZE - 1))
> +	 * will evaluate non-zero and be less than PAGE_SIZE and
>  	 * hence give us the correct page_dirty count. On any other page,
>  	 * it will be zero and in that case we need page_dirty to be the
>  	 * count of buffers on the page.
> @@ -1829,7 +1829,7 @@ xfs_vm_write_begin(
>  	struct page		*page;
>  	int			status;
>  
> -	ASSERT(len <= PAGE_CACHE_SIZE);
> +	ASSERT(len <= PAGE_SIZE);
>  
>  	page = grab_cache_page_write_begin(mapping, index, flags);
>  	if (!page)
> @@ -1882,7 +1882,7 @@ xfs_vm_write_end(
>  {
>  	int			ret;
>  
> -	ASSERT(len <= PAGE_CACHE_SIZE);
> +	ASSERT(len <= PAGE_SIZE);
>  
>  	ret = generic_write_end(file, mapping, pos, len, copied, page, fsdata);
>  	if (unlikely(ret < len)) {
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index aadd6fe75f8f..89f1d5e064a9 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
> @@ -547,10 +547,10 @@ xfs_max_file_offset(
>  	/* Figure out maximum filesize, on Linux this can depend on
>  	 * the filesystem blocksize (on 32 bit platforms).
>  	 * __block_write_begin does this in an [unsigned] long...
> -	 *      page->index << (PAGE_CACHE_SHIFT - bbits)
> +	 *      page->index << (PAGE_SHIFT - bbits)
>  	 * So, for page sized blocks (4K on 32 bit platforms),
>  	 * this wraps at around 8Tb (hence MAX_LFS_FILESIZE which is
> -	 *      (((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)
> +	 *      (((u64)PAGE_SIZE << (BITS_PER_LONG-1))-1)
>  	 * but for smaller blocksizes it is less (bbits = log2 bsize).
>  	 * Note1: get_block_t takes a long (implicit cast from above)
>  	 * Note2: The Large Block Device (LBD and HAVE_SECTOR_T) patch
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> index 1b4d69f68c33..3f103076d0bf 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -135,7 +135,7 @@ struct bdi_writeback {
>  
>  struct backing_dev_info {
>  	struct list_head bdi_list;
> -	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
> +	unsigned long ra_pages;	/* max readahead in PAGE_SIZE units */
>  	unsigned int capabilities; /* Device capabilities */
>  	congested_fn *congested_fn; /* Function pointer if device is md/dm */
>  	void *congested_data;	/* Pointer to aux data for congested func */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 450fc977ed02..ce2378233136 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -623,7 +623,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>   *
>   * A page may belong to an inode's memory mapping. In this case, page->mapping
>   * is the pointer to the inode, and page->index is the file offset of the page,
> - * in units of PAGE_CACHE_SIZE.
> + * in units of PAGE_SIZE.
>   *
>   * If pagecache pages are not associated with an inode, they are said to be
>   * anonymous pages. These may become associated with the swapcache, and in that
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 944b2b37313b..c2d75b4fa86c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -341,7 +341,7 @@ struct vm_area_struct {
>  
>  	/* Information about our backing store: */
>  	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
> -					   units, *not* PAGE_CACHE_SIZE */
> +					   units */
>  	struct file * vm_file;		/* File we map to (can be NULL). */
>  	void * vm_private_data;		/* was vm_pte (shared mem) */
>  
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index efada239205e..957049f72290 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -41,8 +41,8 @@ struct nfs_page {
>  	struct page		*wb_page;	/* page to read in/write out */
>  	struct nfs_open_context	*wb_context;	/* File state context info */
>  	struct nfs_lock_context	*wb_lock_context;	/* lock context info */
> -	pgoff_t			wb_index;	/* Offset >> PAGE_CACHE_SHIFT */
> -	unsigned int		wb_offset,	/* Offset & ~PAGE_CACHE_MASK */
> +	pgoff_t			wb_index;	/* Offset >> PAGE_SHIFT */
> +	unsigned int		wb_offset,	/* Offset & ~PAGE_MASK */
>  				wb_pgbase,	/* Start of page data */
>  				wb_bytes;	/* Length of request */
>  	struct kref		wb_kref;	/* reference count */
> diff --git a/include/linux/nilfs2_fs.h b/include/linux/nilfs2_fs.h
> index 9abb763e4b86..e9fcf90b270d 100644
> --- a/include/linux/nilfs2_fs.h
> +++ b/include/linux/nilfs2_fs.h
> @@ -331,7 +331,7 @@ static inline unsigned nilfs_rec_len_from_disk(__le16 dlen)
>  {
>  	unsigned len = le16_to_cpu(dlen);
>  
> -#if !defined(__KERNEL__) || (PAGE_CACHE_SIZE >= 65536)
> +#if !defined(__KERNEL__) || (PAGE_SIZE >= 65536)
>  	if (len == NILFS_MAX_REC_LEN)
>  		return 1 << 16;
>  #endif
> @@ -340,7 +340,7 @@ static inline unsigned nilfs_rec_len_from_disk(__le16 dlen)
>  
>  static inline __le16 nilfs_rec_len_to_disk(unsigned len)
>  {
> -#if !defined(__KERNEL__) || (PAGE_CACHE_SIZE >= 65536)
> +#if !defined(__KERNEL__) || (PAGE_SIZE >= 65536)
>  	if (len == (1 << 16))
>  		return cpu_to_le16(NILFS_MAX_REC_LEN);
>  	else if (len > (1 << 16))
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index f396ccb900cc..b3fc0370c14f 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -535,8 +535,7 @@ extern void add_page_wait_queue(struct page *page, wait_queue_t *waiter);
>  /*
>   * Fault a userspace page into pagetables.  Return non-zero on a fault.
>   *
> - * This assumes that two userspace pages are always sufficient.  That's
> - * not true if PAGE_CACHE_SIZE > PAGE_SIZE.
> + * This assumes that two userspace pages are always sufficient.
>   */
>  static inline int fault_in_pages_writeable(char __user *uaddr, int size)
>  {
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index cc0fc712bb82..7ca44fb5b675 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -129,7 +129,7 @@ static inline void svc_get(struct svc_serv *serv)
>   *
>   * These happen to all be powers of 2, which is not strictly
>   * necessary but helps enforce the real limitation, which is
> - * that they should be multiples of PAGE_CACHE_SIZE.
> + * that they should be multiples of PAGE_SIZE.
>   *
>   * For UDP transports, a block plus NFS,RPC, and UDP headers
>   * has to fit into the IP datagram limit of 64K.  The largest
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 3d980ea1c946..2b83359c19ca 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -433,7 +433,7 @@ struct backing_dev_info;
>  #define si_swapinfo(val) \
>  	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
>  /* only sparc can not include linux/pagemap.h in this file
> - * so leave page_cache_release and release_pages undeclared... */
> + * so leave put_page and release_pages undeclared... */
>  #define free_page_and_swap_cache(page) \
>  	put_page(page)
>  #define free_pages_and_swap_cache(pages, nr) \
> diff --git a/mm/gup.c b/mm/gup.c
> index 7f1c4fb77cfa..fb87aea9edc8 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1107,7 +1107,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
>   * @addr: user address
>   *
>   * Returns struct page pointer of user page pinned for dump,
> - * to be freed afterwards by page_cache_release() or put_page().
> + * to be freed afterwards by put_page().
>   *
>   * Returns NULL on any kind of failure - a hole must then be inserted into
>   * the corefile, to preserve alignment with its headers; and also returns
> diff --git a/mm/memory.c b/mm/memory.c
> index a2b97af99124..6b979135f59f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2397,7 +2397,6 @@ static inline void unmap_mapping_range_tree(struct rb_root *root,
>  
>  		vba = vma->vm_pgoff;
>  		vea = vba + vma_pages(vma) - 1;
> -		/* Assume for now that PAGE_CACHE_SHIFT == PAGE_SHIFT */
>  		zba = details->first_index;
>  		if (zba < vba)
>  			zba = vba;
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 8551c0b53519..012a4659e273 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -211,7 +211,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>   * return values:
>   *  zero    - success
>   *  -EFAULT - vec points to an illegal address
> - *  -EINVAL - addr is not a multiple of PAGE_CACHE_SIZE
> + *  -EINVAL - addr is not a multiple of PAGE_SIZE
>   *  -ENOMEM - Addresses in the range [addr, addr + len] are
>   *		invalid for the address space of this process, or
>   *		specify one or more pages which are not currently
> @@ -233,7 +233,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
>  	if (!access_ok(VERIFY_READ, (void __user *) start, len))
>  		return -ENOMEM;
>  
> -	/* This also avoids any overflows on PAGE_CACHE_ALIGN */
> +	/* This also avoids any overflows on PAGE_ALIGN */
>  	pages = len >> PAGE_SHIFT;
>  	pages += (offset_in_page(len)) != 0;
>  
> diff --git a/mm/swap.c b/mm/swap.c
> index ea641e247033..a0bc206b4ac6 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -698,7 +698,7 @@ void lru_add_drain_all(void)
>  }
>  
>  /**
> - * release_pages - batched page_cache_release()
> + * release_pages - batched put_page()
>   * @pages: array of pages to release
>   * @nr: number of pages
>   * @cold: whether the pages are cache cold
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 1e6aba0501a1..6bdb3865212d 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -164,7 +164,7 @@ EXPORT_SYMBOL_GPL(xdr_inline_pages);
>   * Note: the addresses pgto_base and pgfrom_base are both calculated in
>   *       the same way:
>   *            if a memory area starts at byte 'base' in page 'pages[i]',
> - *            then its address is given as (i << PAGE_CACHE_SHIFT) + base
> + *            then its address is given as (i << PAGE_SHIFT) + base
>   * Also note: pgfrom_base must be < pgto_base, but the memory areas
>   * 	they point to may overlap.
>   */
> -- 
> 2.7.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
