Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82A03C433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14A7D2086D
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B1sMPAcs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14A7D2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7801B6B0003; Sun,  4 Aug 2019 18:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 709316B0005; Sun,  4 Aug 2019 18:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A90F6B0006; Sun,  4 Aug 2019 18:49:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7246B0003
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:21 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so52125240pfo.22
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=YZWsn+x3jxp8fDI44kijDFRG/svqEg676iUchgN7QlQ=;
        b=Fc70kzhkEHwDVk0YIsX23i8J76eTSUzeukRMslyMdiNXF4RWOuA9fIqzyuTtiOp4Yp
         IR3iT7CWLkjdGHtY35t6qIj7VDBtI1m7FLyYYIHaV3KcnwXVlvL/Dh3vxZz610ldC4Dq
         HD/e+MlCVLeQSWa5z201BxNMVaKdVm42ApvLBeXs11oMZZn7jFaiCuxfjoTtkqrIYA+I
         BiePzCHQPtPLJ2J8pITWRxIAwD81qQqzKB9HY6aIL3TntYzH1XQQ4OHqLoodp/RG0k7o
         3NSd5sZRCpCijow7jgudhP6MPENnse79bVjuGv3x48qwxaYAiSng4r119wLnyvwg9L7c
         kbeQ==
X-Gm-Message-State: APjAAAWLMcyNpreAB8iMxtoxfPvj8vqQUSp4aO7khmphsTzfWX5trFRm
	qmNgAYYoq9vU+08j5zDPrgtfawKP+1Jjt2N9eZTzj2UGIljCdwUnnv91Qa9yK6qmM8ZYxBxA7Tx
	U/6kEgnhOhZ2DhQQryeoqaEMEjd3SNDfoT9ik2A4NbT2EHShIeEAbGEAXKoIYXFtR+w==
X-Received: by 2002:a62:750c:: with SMTP id q12mr72269076pfc.59.1564958960641;
        Sun, 04 Aug 2019 15:49:20 -0700 (PDT)
X-Received: by 2002:a62:750c:: with SMTP id q12mr72269046pfc.59.1564958959445;
        Sun, 04 Aug 2019 15:49:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958959; cv=none;
        d=google.com; s=arc-20160816;
        b=X3w5D+8Iy1GFx0nYGyMdadPArtF5M7VRrrtqgdZoru/xDidp/gEW+fIKjQxwDhovZP
         G8hHjmRay2eljiNEZkVuIbOu9D9hbFRWbA8r8CuSP0G1zyStb0LmusBfiBY7xjIC5GAN
         fQKeUaHlufAB2cmOmCiQi9HyfC6XyvHLITIRD+/9ycyvJg/8QMC168XtfuRhXW8J8eFe
         vOvILzardoVQBCZnLN7cihAmluKM8CFQMH4fvQslICQFLJ3PcV2kjjHDgJSU9H8Jl6MZ
         GjlRRZbNU87zI4KL0MNzZ38KL18pdPbqbAIPyth2clwN4XfxPuWSU4RRkklVbgVYolFA
         OA+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=YZWsn+x3jxp8fDI44kijDFRG/svqEg676iUchgN7QlQ=;
        b=SKtvEqA3GM/wVUkOEgtL3ejCGzHMNKFz/AVbCBSYysOG6V2kcSEzMwRZrRd6lzV9Dp
         Li2AZCUG7ByFSMSbfGoedquNCpm0CM3JOEnTx1Gvi4Crql19B87W52aEgH4m6iDlTLNx
         EZ4p43t6rWEKFld+KNzuIF0wBBVBntCRqMRzLWyxQMYPMimTMns2ZmWoTfVc+dTQNZle
         0IYRAmYzP4lQczrxOCz8KsxPjapet37NJnmt9Bj0Si2O39VjmMvGfsAQNrXJG8w/ztWB
         xb3km79WcqG+KeSBNUOtGnrK4WLMbu1mGP+bUggsP10ETF6qmgwLdPW7pi9foN4MBShe
         p3FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B1sMPAcs;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor5228305plq.67.2019.08.04.15.49.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B1sMPAcs;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YZWsn+x3jxp8fDI44kijDFRG/svqEg676iUchgN7QlQ=;
        b=B1sMPAcstI1puFk4w0cpCwyzsYpSCgnvkOWm4iaJnV8UBmRJR0FrVO7eeE2XgV7/DO
         DR3tgluGLB1/vbyPlZSBhbH+uo9CrzBJ1Q1rSPrUCEwEtdEEdHEsEYUhdaEO6ERTThp5
         mEExF0x3pWqACoKcpQ4jZSYPKI1ZJek74ypeshcY0SnsNOjJI1e96tP2zvVBSu1jKr+e
         Ym/g1QeiNeLfwG1YUwV1crKOGP7UibjO/7uqLpqDUr9tSTViDlNhIsYnzcFJ7cH459WG
         UptxQms1lJSvYFzHsJjq9KZpFUhZyY+WV1c+r9r6Bw6gMAdbrBCCcRHzjatxpXqpGNbN
         SemQ==
X-Google-Smtp-Source: APXvYqxKaZcQUZ6UkPpcjP3XTdHmlP5C8HsDSLXmXJQis54EHd1b2U7WGwbPzUzQrFqhwr6YKPwdiw==
X-Received: by 2002:a17:902:a413:: with SMTP id p19mr142672660plq.134.1564958958984;
        Sun, 04 Aug 2019 15:49:18 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:18 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v2 00/34] put_user_pages(): miscellaneous call sites
Date: Sun,  4 Aug 2019 15:48:41 -0700
Message-Id: <20190804224915.28669-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Changes since v1:

* 9 out of 34 patches have been reviewed or ack'd or changed:
    * Picked up Keith's Reviewed-by for patch 26 (gup_benchmark).
    * Picked up ACKs for patches 3, 10, 15, 16 (ceph, genwqe,
      staging/vc04_services, drivers/tee).

* Patch 6 (i915): adjusted drivers/gpu/drm/i915/gem/i915_gem_userptr.c to
  match the latest linux.git: the code has already been fixed in linux.git,
  as of the latest -rc, to do a set_page_dirty_lock(), instead of
  set_page_dirty(). So all that it needs now is a conversion to
  put_user_page(). I've done that in a way (avoiding the changed API call)
  that allows patch 6 to go up via either Andrew's -mm tree, or the drm
  tree, just in case. See that patch's comments for slightly more detail.

* Patch 20 (xen): applied Juergen's recommended fix, and speculatively
  (pending his approval) added his Signed-off-by (also noted in the patch
  comments).

* Improved patch 31 (NFS) as recommended by Calum Mackay.

* Includes the latest version of patch 1. (Patch 1 has been separately
  reposted [3], with those updates. And it's included here in order to
  make this series apply directly to linux.git, as noted in the original
  cover letter below.)

Cover letter from v1:

These are best characterized as miscellaneous conversions: many (not all)
call sites that don't involve biovec or iov_iter, nor mm/. It also leaves
out a few call sites that require some more work. These are mostly pretty
simple ones.

It's probably best to send all of these via Andrew's -mm tree, assuming
that there are no significant merge conflicts with ongoing work in other
trees (which I doubt, given that these are small changes).

These patches apply to the latest linux.git. Patch #1 is also already in
Andrew's tree, but given the broad non-linux-mm Cc list, I thought it
would be more convenient to just include that patch here, so that people
can use linux.git as the base--even though these are probably destined
for linux-mm.

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions"). That commit
has an extensive description of the problem and the planned steps to
solve it, but the highlites are:

1) Provide put_user_page*() routines, intended to be used
for releasing pages that were pinned via get_user_pages*().

2) Convert all of the call sites for get_user_pages*(), to
invoke put_user_page*(), instead of put_page(). This involves dozens of
call sites, and will take some time.

3) After (2) is complete, use get_user_pages*() and put_user_page*() to
implement tracking of these pages. This tracking will be separate from
the existing struct page refcounting.

4) Use the tracking and identification of these pages, to implement
special handling (especially in writeback paths) when the pages are
backed by a filesystem.

And a few references, also from that commit:

[1] https://lwn.net/Articles/774411/ : "DMA and get_user_pages()"
[2] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[3] "mm/gup: add make_dirty arg to put_user_pages_dirty_lock()"
    https://lore.kernel.org/r/20190804214042.4564-1-jhubbard@nvidia.com

Ira Weiny (1):
  fs/binfmt_elf: convert put_page() to put_user_page*()

John Hubbard (33):
  mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
  net/rds: convert put_page() to put_user_page*()
  net/ceph: convert put_page() to put_user_page*()
  x86/kvm: convert put_page() to put_user_page*()
  drm/etnaviv: convert release_pages() to put_user_pages()
  drm/i915: convert put_page() to put_user_page*()
  drm/radeon: convert put_page() to put_user_page*()
  media/ivtv: convert put_page() to put_user_page*()
  media/v4l2-core/mm: convert put_page() to put_user_page*()
  genwqe: convert put_page() to put_user_page*()
  scif: convert put_page() to put_user_page*()
  vmci: convert put_page() to put_user_page*()
  rapidio: convert put_page() to put_user_page*()
  oradax: convert put_page() to put_user_page*()
  staging/vc04_services: convert put_page() to put_user_page*()
  drivers/tee: convert put_page() to put_user_page*()
  vfio: convert put_page() to put_user_page*()
  fbdev/pvr2fb: convert put_page() to put_user_page*()
  fsl_hypervisor: convert put_page() to put_user_page*()
  fs/exec.c: convert put_page() to put_user_page*()
  xen: convert put_page() to put_user_page*()
  orangefs: convert put_page() to put_user_page*()
  uprobes: convert put_page() to put_user_page*()
  futex: convert put_page() to put_user_page*()
  mm/frame_vector.c: convert put_page() to put_user_page*()
  mm/gup_benchmark.c: convert put_page() to put_user_page*()
  mm/memory.c: convert put_page() to put_user_page*()
  mm/madvise.c: convert put_page() to put_user_page*()
  mm/process_vm_access.c: convert put_page() to put_user_page*()
  crypt: convert put_page() to put_user_page*()
  fs/nfs: convert put_page() to put_user_page*()
  goldfish_pipe: convert put_page() to put_user_page*()
  kernel/events/core.c: convert put_page() to put_user_page*()

 arch/x86/kvm/svm.c                            |   4 +-
 crypto/af_alg.c                               |   7 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c         |   4 +-
 drivers/gpu/drm/i915/gem/i915_gem_userptr.c   |   6 +-
 drivers/gpu/drm/radeon/radeon_ttm.c           |   2 +-
 drivers/infiniband/core/umem.c                |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c       |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c    |  13 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c      |   5 +-
 drivers/infiniband/sw/siw/siw_mem.c           |  19 +--
 drivers/media/pci/ivtv/ivtv-udma.c            |  14 +--
 drivers/media/pci/ivtv/ivtv-yuv.c             |  11 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c     |   3 +-
 drivers/misc/genwqe/card_utils.c              |  17 +--
 drivers/misc/mic/scif/scif_rma.c              |  17 ++-
 drivers/misc/vmw_vmci/vmci_context.c          |   2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c       |  11 +-
 drivers/platform/goldfish/goldfish_pipe.c     |   9 +-
 drivers/rapidio/devices/rio_mport_cdev.c      |   9 +-
 drivers/sbus/char/oradax.c                    |   2 +-
 .../interface/vchiq_arm/vchiq_2835_arm.c      |  10 +-
 drivers/tee/tee_shm.c                         |  10 +-
 drivers/vfio/vfio_iommu_type1.c               |   8 +-
 drivers/video/fbdev/pvr2fb.c                  |   3 +-
 drivers/virt/fsl_hypervisor.c                 |   7 +-
 drivers/xen/privcmd.c                         |  32 ++---
 fs/binfmt_elf.c                               |   2 +-
 fs/binfmt_elf_fdpic.c                         |   2 +-
 fs/exec.c                                     |   2 +-
 fs/nfs/direct.c                               |  11 +-
 fs/orangefs/orangefs-bufmap.c                 |   7 +-
 include/linux/mm.h                            |   5 +-
 kernel/events/core.c                          |   2 +-
 kernel/events/uprobes.c                       |   6 +-
 kernel/futex.c                                |  10 +-
 mm/frame_vector.c                             |   4 +-
 mm/gup.c                                      | 115 ++++++++----------
 mm/gup_benchmark.c                            |   2 +-
 mm/madvise.c                                  |   2 +-
 mm/memory.c                                   |   2 +-
 mm/process_vm_access.c                        |  18 +--
 net/ceph/pagevec.c                            |   8 +-
 net/rds/info.c                                |   5 +-
 net/rds/message.c                             |   2 +-
 net/rds/rdma.c                                |  15 ++-
 virt/kvm/kvm_main.c                           |   4 +-
 46 files changed, 164 insertions(+), 295 deletions(-)

-- 
2.22.0

