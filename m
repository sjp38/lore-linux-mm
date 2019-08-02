Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 888ADC32754
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 332302084C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WgvMYxfg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 332302084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D218C6B0005; Thu,  1 Aug 2019 22:20:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD0E56B0006; Thu,  1 Aug 2019 22:20:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B98796B0008; Thu,  1 Aug 2019 22:20:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 800426B0005
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y66so47104522pfb.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=3GzlMAdD/Fj4tpT1z/PK8Fr3raamoGX6ZwkHP2yb6K8=;
        b=sNuE1gsMvnEAm5/lUseHjWuUJ8hgdIQBk1KDhTRrY3T9LGmCBswGCzfb6ZPu4A+Zn0
         BoE/yBwxSU5zB1ixpcMQS8Ho+aaexUB8+ZyTZm0MfF31S3CctP/NoorRgfLOkQr92Tbw
         C0I5ixF/zJJYH0/5ydNVTUpkhrAh6J5SQNckS5cL8xKAVmVDD2OKfpylxO4x/4+QS5kF
         ygYh8ia84YkGDQtcV93KNR7R2qoq9TaZ2Qyh9mtOlxjuVortNWc56tVMzYEm/QGTHsQR
         jCmildltNmaqidMc3zcwqAX9LIE/hJp9xRAXLWGprwLrwIPFVez/VfB8/GxkeYEJazvB
         85HQ==
X-Gm-Message-State: APjAAAWInFgI7RWkV2bmIti3exWUlTngDBxH/a52+nzOGlVP73zopJGp
	PIcBGjhTbPNWymapbBYlqktfhOWwh/fXrr8p6+Hg37T5nlAlsSS7+2RF8Z/bNpgWHUDn10o6N7h
	BvWhJPI2wyPkGzGXxepw3xMrSbk2zpcZ+jJG+/ZSkltwGIdqlIK3kWDkbzCiUb8wILw==
X-Received: by 2002:aa7:9531:: with SMTP id c17mr58947536pfp.130.1564712413102;
        Thu, 01 Aug 2019 19:20:13 -0700 (PDT)
X-Received: by 2002:aa7:9531:: with SMTP id c17mr58947469pfp.130.1564712412263;
        Thu, 01 Aug 2019 19:20:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712412; cv=none;
        d=google.com; s=arc-20160816;
        b=OP6ZfGs3e06Ppd3pqBQkjFzmheEiiC74ggmtataeV01BjXLadWzBIYhfb6yzhdtJtg
         FnKLciXXhkQ1qW6VUx7CPTZB6jo0UWZ7Pdw4gayby/aplFjeJjuSAM0xsQ832MDUDtiN
         3t+Jw65u9yU+aQmiZwo56whYZ08GQ39lYzmMFcodBW9q7BKzG22KbzeeXH6wFhiB4Ehy
         R8KzRZgELq7tIKFtqV0sgj4t7C6mEAf5jPizpc46h7dMyN3ncoRFNE4TJVuMmojtXz/Z
         we958SS8sjaX85xgPLDukm4H/TjxxnVtgGws5a4Zk3SHihTAReg3mmM3SPlnCd/BXMhc
         1sIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=3GzlMAdD/Fj4tpT1z/PK8Fr3raamoGX6ZwkHP2yb6K8=;
        b=y5xqNlaqDlBKyc/80u1ocxPb2ahRrj6dTrEIatk7zYdMFgSzzSZMOeAZr36Aoy99Rz
         oZNN4e6Tb5nnbdKPIKIOdh92CFRf+wmunlVSjsPV4w5z92lL8C0rvpH2krw0O7vromXG
         oxC1oFY3ptjA0Lrj4oq/zTqb+OVhplSSOkPmEGolLh8KBUQ4jQn2uhjgQm0kQy5duwzm
         u1SByCc672rCE/CAmtj2rgdYzXqbFiEQ26B+PDlO1/9Ap7YzjtjZsieWGFcNUA2N9g8N
         w+NzrLa3hZ2jW8a5fkcH1cLIR+8a4nZM9dDJ+7W4/wqab7MJzed9AVJZIsiwy1/15VTn
         2GZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WgvMYxfg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a6sor29834315pgt.14.2019.08.01.19.20.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WgvMYxfg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3GzlMAdD/Fj4tpT1z/PK8Fr3raamoGX6ZwkHP2yb6K8=;
        b=WgvMYxfgb6Molfspondn33ZYB1WcvyhUHuuLQJHqj92K0W/u5k0B5ZQj1BN5Ns2IZE
         M0GWxKjoZrIPc//wnMwUJTmV5TMSYpm02fQgVP/BH2szNXvyzzeOa5FiDRKrjlN3+luO
         9Jy7V18qn+4b0ojFo/dXh7wBvGZvx4G8yqL9GdVH2uaO753yJYW/vuKj6Ghg+xpVFc5A
         N5wBHvH3PD3PXLn+hz8omKP+6e2hjXrqsj1JOQPHhNWSLJbaM8A5usTldb4lWZTBhIo0
         mLxHVdEO0uyXR6yvbfmKtCZaa5xv6j5LsvjMwT4z5+CpizIhX6UVhXHqVJggfrPMULjn
         H4uA==
X-Google-Smtp-Source: APXvYqxheUI3U4eMXPfQOAu0iMAgy84p0nt5Unb4jdDMlWNxu88KGGVSWktP7DU/iS6MqE4v20pMKQ==
X-Received: by 2002:a63:550d:: with SMTP id j13mr59450607pgb.173.1564712411856;
        Thu, 01 Aug 2019 19:20:11 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:11 -0700 (PDT)
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
Subject: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Date: Thu,  1 Aug 2019 19:19:31 -0700
Message-Id: <20190802022005.5117-1-jhubbard@nvidia.com>
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

Hi,

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
  xen: convert put_page() to put_user_page*()
  fs/exec.c: convert put_page() to put_user_page*()
  orangefs: convert put_page() to put_user_page*()
  uprobes: convert put_page() to put_user_page*()
  futex: convert put_page() to put_user_page*()
  mm/frame_vector.c: convert put_page() to put_user_page*()
  mm/gup_benchmark.c: convert put_page() to put_user_page*()
  mm/memory.c: convert put_page() to put_user_page*()
  mm/madvise.c: convert put_page() to put_user_page*()
  mm/process_vm_access.c: convert put_page() to put_user_page*()
  crypt: convert put_page() to put_user_page*()
  nfs: convert put_page() to put_user_page*()
  goldfish_pipe: convert put_page() to put_user_page*()
  kernel/events/core.c: convert put_page() to put_user_page*()

 arch/x86/kvm/svm.c                            |   4 +-
 crypto/af_alg.c                               |   7 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c         |   4 +-
 drivers/gpu/drm/i915/gem/i915_gem_userptr.c   |   9 +-
 drivers/gpu/drm/radeon/radeon_ttm.c           |   2 +-
 drivers/infiniband/core/umem.c                |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c       |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c    |   5 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c      |   5 +-
 drivers/infiniband/sw/siw/siw_mem.c           |  10 +-
 drivers/media/pci/ivtv/ivtv-udma.c            |  14 +--
 drivers/media/pci/ivtv/ivtv-yuv.c             |  10 +-
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
 drivers/xen/gntdev.c                          |   5 +-
 drivers/xen/privcmd.c                         |   7 +-
 fs/binfmt_elf.c                               |   2 +-
 fs/binfmt_elf_fdpic.c                         |   2 +-
 fs/exec.c                                     |   2 +-
 fs/nfs/direct.c                               |   4 +-
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
 47 files changed, 151 insertions(+), 266 deletions(-)

-- 
2.22.0

