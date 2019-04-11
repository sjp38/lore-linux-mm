Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 556EEC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01F4F20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01F4F20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 795E26B0269; Thu, 11 Apr 2019 17:08:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 744356B026A; Thu, 11 Apr 2019 17:08:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C1076B026B; Thu, 11 Apr 2019 17:08:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3761D6B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:08:47 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s70so6278026qka.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:08:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=pmka8etphlLghHz940Qk8BQdfAQ3LC5B6vfpSwUwQxI=;
        b=nPM3u8bDq+tpwdD+Sd7qhWO25zyx01llXyUNm8cRbsjir1Vz6ULh4HPbew+CcSDYoo
         lCZn2IeV8g3MsnK7LVWIA5cExbwzv9a1WFQRbvk6yHPpn2j8oP8yzkF3hyClao8lUHwH
         /9ZjT4+gVZwK1MVOeOOf/Vwq+Hw6Im88jBWHY5Rfn67oOP67pfVz3yxJ7ohRJ/NwPKum
         1QjqZev1h+FftwHhvt8BnCj1GJwj57n+1V1/iAJhRPNVQvHQCyFWjldkpHGifFhAkuXC
         RZr7z3BAHkroTSdLHXEw8FhfgAnKyIXhBzoHwqb/VT2ZOqIy524XE4SPHjheHBh1x0hj
         HnJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAULIGc65DLNoSEWl0Wn8cfSFZkUZGCOVBdsdyxh18k8r3Qx0GCc
	JcBLmgRZ+H64dXsBIEm8mNMEOsp3+sSKHdUiIyf/+lyjmlICLNNOPD/SAKUQgc8KvSRdx642F66
	25y/P0vp+1hJT6UQlaa/bdytR5rdJz1a6kO5B/Gfi84iEr1geiRim+KjPbn9piiRgAQ==
X-Received: by 2002:a0c:8a59:: with SMTP id 25mr43019438qvu.191.1555016926930;
        Thu, 11 Apr 2019 14:08:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzxnevx0CBh1vP+qnZ5mbLESviUP45xnl+zYgUqCPS7qRkWkvbQbgj7zc621mAwBubXYSJ
X-Received: by 2002:a0c:8a59:: with SMTP id 25mr43019347qvu.191.1555016925847;
        Thu, 11 Apr 2019 14:08:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016925; cv=none;
        d=google.com; s=arc-20160816;
        b=XYnmW39qKQ2SyhU2uFTEcWcSPlViCyNNYWLH0zGMabX/l7wI41P9B8+Gpr+m562H+l
         YMUi3oJDnlc2Kfn0hAeY2dVNkjhpccq06CjbfNH/ZlYGY7XSoUW5W5NKMrqr3sZiGGE1
         QskOcWiTEem/BfUtXLEtJ5hrhgRPhqtehUZiyfu+hj04SE7vcgySYmU9++lCDLeToJcW
         21kRcRChDGm90hXuNo9phfQuoLgjTc3X58N2dhxV9JjqlPCGRmf25YmlMJmjM+NrzWLT
         baXwhHIfifgoS3Y72JsZb12nfDCMRzEly2UQdpq8ESsW7IlQzWSk76ikxL643OVFLPPD
         HTZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=pmka8etphlLghHz940Qk8BQdfAQ3LC5B6vfpSwUwQxI=;
        b=U8IpplzkjXNHHe68TValNHidEH9Wr59lHGmHqAx6kFRALIPdSseqslBSOgsfJJ/joZ
         4cW4emQHUP77BldM2ZHPNE+QQYMNgZSb8qrlB4Ab4rvBpaFepMAZoQX9bmMsgi0JwXiC
         j2zxxlRlrFVMtWM8kMq0afqPFjg0rpJALfMLrdycc51xoMCLtfSH4/maecrWRKpHzcZc
         wxdbtSgyCtotXyFJARLdvXD60FotQY7bAR5KfRxi1SS0zdl8GYBZ2GxxOZwLDEkELqs5
         4JpIvF2k/QwwAMbshaQAw3lSJLi1ROkwqzPfwMiVr7CeabdXqRvmxwL8HUenPyNH7rqn
         aF+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u24si51283qte.394.2019.04.11.14.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:08:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7913A307CB29;
	Thu, 11 Apr 2019 21:08:44 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 92DB85C21E;
	Thu, 11 Apr 2019 21:08:36 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>,
	linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org,
	Yan Zheng <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Elder <elder@kernel.org>,
	ceph-devel@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	devel@lists.orangefs.org,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net,
	Coly Li <colyli@suse.de>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	linux-bcache@vger.kernel.org,
	=?UTF-8?q?Ernesto=20A=20=2E=20Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Date: Thu, 11 Apr 2019 17:08:19 -0400
Message-Id: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 11 Apr 2019 21:08:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patchset depends on various small fixes [1] and also on patchset
which introduce put_user_page*() [2] and thus is 5.3 material as those
pre-requisite will get in 5.2 at best. Nonetheless i am posting it now
so that it can get review and comments on how and what should be done
to test things.

For various reasons [2] [3] we want to track page reference through GUP
differently than "regular" page reference. Thus we need to keep track
of how we got a page within the block and fs layer. To do so this patch-
set change the bio_bvec struct to store a pfn and flags instead of a
direct pointer to a page. This way we can flag page that are coming from
GUP.

This patchset is divided as follow:
    - First part of the patchset is just small cleanup i believe they
      can go in as his assuming people are ok with them.
    - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
      done in multi-step, first we replace all direct dereference of
      the field by call to inline helper, then we introduce macro for
      bio_bvec that are initialized on the stack. Finaly we change the
      bv_page field to bv_pfn.
    - Third part replace put_page(bv_page(bio_vec)) with a new helper
      which will use put_user_page() when the page in the bio_vec is
      coming from GUP.
    - Fourth part update BIO to use bv_set_user_page() for page that
      are coming from GUP this means updating bio_add_page*() to pass
      down the origin of the page (GUP or not).
    - Fith part convert few more places that directly use bvec_io or
      BIO.

Note that after this patchset they are still places in the kernel where
we should use put_user_page*(). The intention is to separate that task
in chewable chunk (driver by driver, sub-system by sub-system).


I have only lightly tested this patchset (branch [4]) on my desktop and
have not seen anything obviously wrong but i might have miss something.
What kind of test suite should i run to stress test the vfs/block layer
around DIO and BIO ?


Note that you coccinelle [5] recent enough for the semantic patch to work
properly ([5] with git commit >= eac73d191e4f03d759957fc5620062428fadada8).

Cheers,
Jérôme Glisse

[1] https://cgit.freedesktop.org/~glisse/linux/commit/?h=gup-fs-block&id=5f67db69fd9f95d12987d2a030a82bc390e05a71
    https://cgit.freedesktop.org/~glisse/linux/commit/?h=gup-fs-block&id=b070348d0e1fd9397eb8d0e97b4c89f1d04d5a0a
    https://cgit.freedesktop.org/~glisse/linux/commit/?h=gup-fs-block&id=83691c86a6c8f560b5b78f3f57fcd62c0f3f1c7a
[2] https://lkml.org/lkml/2019/3/26/1395
[3] https://lwn.net/Articles/753027/
[4] https://cgit.freedesktop.org/~glisse/linux/log/?h=gup-fs-block
[5] https://github.com/coccinelle/coccinelle

Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Steve French <sfrench@samba.org>
Cc: linux-cifs@vger.kernel.org
Cc: samba-technical@lists.samba.org
Cc: Yan Zheng <zyan@redhat.com>
Cc: Sage Weil <sage@redhat.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Alex Elder <elder@kernel.org>
Cc: ceph-devel@vger.kernel.org
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: devel@lists.orangefs.org
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: v9fs-developer@lists.sourceforge.net
Cc: Coly Li <colyli@suse.de>
Cc: Kent Overstreet <kent.overstreet@gmail.com>
Cc: linux-bcache@vger.kernel.org
Cc: Ernesto A. Fernández <ernesto.mnd.fernandez@gmail.com>

Jérôme Glisse (15):
  fs/direct-io: fix trailing whitespace issues
  iov_iter: add helper to test if an iter would use GUP
  block: introduce bvec_page()/bvec_set_page() to get/set
    bio_vec.bv_page
  block: introduce BIO_VEC_INIT() macro to initialize bio_vec structure
  block: replace all bio_vec->bv_page by bvec_page()/bvec_set_page()
  block: convert bio_vec.bv_page to bv_pfn to store pfn and not page
  block: add bvec_put_page_dirty*() to replace put_page(bvec_page())
  block: use bvec_put_page() instead of put_page(bvec_page())
  block: bvec_put_page_dirty* instead of set_page_dirty* and
    bvec_put_page
  block: add gup flag to
    bio_add_page()/bio_add_pc_page()/__bio_add_page()
  block: make sure bio_add_page*() knows page that are coming from GUP
  fs/direct-io: keep track of wether a page is coming from GUP or not
  fs/splice: use put_user_page() when appropriate
  fs: use bvec_set_gup_page() where appropriate
  ceph: use put_user_pages() instead of ceph_put_page_vector()

 Documentation/block/biodoc.txt      |  7 +-
 arch/m68k/emu/nfblock.c             |  2 +-
 arch/um/drivers/ubd_kern.c          |  2 +-
 arch/xtensa/platforms/iss/simdisk.c |  2 +-
 block/bio-integrity.c               |  8 +--
 block/bio.c                         | 92 ++++++++++++++++-----------
 block/blk-core.c                    |  2 +-
 block/blk-integrity.c               |  7 +-
 block/blk-lib.c                     |  5 +-
 block/blk-merge.c                   |  9 +--
 block/blk.h                         |  4 +-
 block/bounce.c                      | 26 ++++----
 block/t10-pi.c                      |  4 +-
 drivers/block/aoe/aoecmd.c          |  4 +-
 drivers/block/brd.c                 |  2 +-
 drivers/block/drbd/drbd_actlog.c    |  2 +-
 drivers/block/drbd/drbd_bitmap.c    |  4 +-
 drivers/block/drbd/drbd_main.c      |  4 +-
 drivers/block/drbd/drbd_receiver.c  |  6 +-
 drivers/block/drbd/drbd_worker.c    |  2 +-
 drivers/block/floppy.c              |  6 +-
 drivers/block/loop.c                | 16 ++---
 drivers/block/null_blk_main.c       |  6 +-
 drivers/block/pktcdvd.c             |  4 +-
 drivers/block/ps3disk.c             |  2 +-
 drivers/block/ps3vram.c             |  2 +-
 drivers/block/rbd.c                 | 12 ++--
 drivers/block/rsxx/dma.c            |  3 +-
 drivers/block/umem.c                |  2 +-
 drivers/block/virtio_blk.c          |  4 +-
 drivers/block/xen-blkback/blkback.c |  2 +-
 drivers/block/zram/zram_drv.c       | 24 +++----
 drivers/lightnvm/core.c             |  2 +-
 drivers/lightnvm/pblk-core.c        | 12 ++--
 drivers/lightnvm/pblk-rb.c          |  2 +-
 drivers/lightnvm/pblk-read.c        |  6 +-
 drivers/md/bcache/btree.c           |  2 +-
 drivers/md/bcache/debug.c           |  4 +-
 drivers/md/bcache/request.c         |  4 +-
 drivers/md/bcache/super.c           |  6 +-
 drivers/md/bcache/util.c            | 11 ++--
 drivers/md/dm-bufio.c               |  2 +-
 drivers/md/dm-crypt.c               | 18 ++++--
 drivers/md/dm-integrity.c           | 18 +++---
 drivers/md/dm-io.c                  |  7 +-
 drivers/md/dm-log-writes.c          | 20 +++---
 drivers/md/dm-verity-target.c       |  4 +-
 drivers/md/dm-writecache.c          |  3 +-
 drivers/md/dm-zoned-metadata.c      |  6 +-
 drivers/md/md.c                     |  4 +-
 drivers/md/raid1-10.c               |  2 +-
 drivers/md/raid1.c                  |  4 +-
 drivers/md/raid10.c                 |  4 +-
 drivers/md/raid5-cache.c            |  7 +-
 drivers/md/raid5-ppl.c              |  6 +-
 drivers/md/raid5.c                  | 10 +--
 drivers/nvdimm/blk.c                |  6 +-
 drivers/nvdimm/btt.c                |  5 +-
 drivers/nvdimm/pmem.c               |  4 +-
 drivers/nvme/host/core.c            |  4 +-
 drivers/nvme/host/tcp.c             |  2 +-
 drivers/nvme/target/io-cmd-bdev.c   |  2 +-
 drivers/nvme/target/io-cmd-file.c   |  2 +-
 drivers/s390/block/dasd_diag.c      |  2 +-
 drivers/s390/block/dasd_eckd.c      | 14 ++--
 drivers/s390/block/dasd_fba.c       |  6 +-
 drivers/s390/block/dcssblk.c        |  2 +-
 drivers/s390/block/scm_blk.c        |  2 +-
 drivers/s390/block/xpram.c          |  2 +-
 drivers/scsi/sd.c                   | 25 ++++----
 drivers/staging/erofs/data.c        |  6 +-
 drivers/staging/erofs/unzip_vle.c   |  4 +-
 drivers/target/target_core_file.c   |  6 +-
 drivers/target/target_core_iblock.c |  4 +-
 drivers/target/target_core_pscsi.c  |  2 +-
 drivers/xen/biomerge.c              |  4 +-
 fs/9p/vfs_addr.c                    |  4 +-
 fs/afs/fsclient.c                   |  2 +-
 fs/afs/rxrpc.c                      |  4 +-
 fs/afs/yfsclient.c                  |  2 +-
 fs/block_dev.c                      | 10 ++-
 fs/btrfs/check-integrity.c          |  6 +-
 fs/btrfs/compression.c              | 22 +++----
 fs/btrfs/disk-io.c                  |  4 +-
 fs/btrfs/extent_io.c                | 16 ++---
 fs/btrfs/file-item.c                |  8 +--
 fs/btrfs/inode.c                    | 20 +++---
 fs/btrfs/raid56.c                   |  8 +--
 fs/btrfs/scrub.c                    | 10 +--
 fs/buffer.c                         |  4 +-
 fs/ceph/file.c                      | 20 +++---
 fs/cifs/connect.c                   |  4 +-
 fs/cifs/misc.c                      | 14 ++--
 fs/cifs/smb2ops.c                   |  2 +-
 fs/cifs/smbdirect.c                 |  2 +-
 fs/cifs/transport.c                 |  2 +-
 fs/crypto/bio.c                     |  4 +-
 fs/direct-io.c                      | 94 +++++++++++++++++++--------
 fs/ext4/page-io.c                   |  4 +-
 fs/ext4/readpage.c                  |  4 +-
 fs/f2fs/data.c                      | 20 +++---
 fs/gfs2/lops.c                      |  8 +--
 fs/gfs2/meta_io.c                   |  4 +-
 fs/gfs2/ops_fstype.c                |  2 +-
 fs/hfsplus/wrapper.c                |  3 +-
 fs/io_uring.c                       |  4 +-
 fs/iomap.c                          | 10 +--
 fs/jfs/jfs_logmgr.c                 |  4 +-
 fs/jfs/jfs_metapage.c               |  6 +-
 fs/mpage.c                          |  6 +-
 fs/nfs/blocklayout/blocklayout.c    |  2 +-
 fs/nilfs2/segbuf.c                  |  3 +-
 fs/ocfs2/cluster/heartbeat.c        |  2 +-
 fs/orangefs/inode.c                 |  2 +-
 fs/splice.c                         | 13 ++--
 fs/xfs/xfs_aops.c                   |  8 +--
 fs/xfs/xfs_buf.c                    |  2 +-
 include/linux/bio.h                 | 13 ++--
 include/linux/bvec.h                | 99 +++++++++++++++++++++++++----
 include/linux/uio.h                 | 11 ++++
 kernel/power/swap.c                 |  2 +-
 lib/iov_iter.c                      | 32 +++++-----
 mm/page_io.c                        |  8 +--
 net/ceph/messenger.c                | 10 +--
 net/sunrpc/xdr.c                    |  2 +-
 net/sunrpc/xprtsock.c               |  4 +-
 126 files changed, 628 insertions(+), 467 deletions(-)

-- 
2.20.1

