Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C515BC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:17:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 417892080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:17:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pAxzsc9v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 417892080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A159E6B0003; Thu,  1 Aug 2019 22:17:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C7FA6B0005; Thu,  1 Aug 2019 22:17:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88DCF6B0006; Thu,  1 Aug 2019 22:17:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 527896B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:17:00 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g18so40725209plj.19
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:17:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=3GzlMAdD/Fj4tpT1z/PK8Fr3raamoGX6ZwkHP2yb6K8=;
        b=kioODMZLd9H3RSLBb31Fq2T02NET6TITlguVdGGuGiAv6lupGDjmyWMZyHwd8BCh2Y
         wyChg9NhQGIsaiENBixISHDmlKCZJo0sJUnSzbxEWzRVNv/dafe14XRpYaHcEzRBQm3r
         OXXjjn9ULoo1ObUW3XrhjvWOaz64z27vxZW7NuMPAykquLwcY0ZW5h0ypP3y+Qf8NSng
         rmZleKoo9EJzdaUlk0QcLut6M2aCW4gUh0kfkQksqAAWurfqym6DP1xeD35LfC2iSTGg
         05gtfRhniFebCPuzEjPruO2AzfIRF6CkIASlOQiQlapbhN4uDbZkD2E6ai43X20FjOxr
         eXSQ==
X-Gm-Message-State: APjAAAU6vXWj7mvZT67eOEiN6KFvG25HwseVfJXeEobJeEzWFGKSocEB
	VuzdKdPtLz8btF56Xf9wir1HafSFp+3rIyvNuP9IfpSUZiyP3CM5ZdRZA2iRdURoBk4cCR3rvDM
	zuCThCal4inHbpFKdv1bkQ3yuYlRXuCzWwCA3oTzgzPb5yx2KVU1RpMmKB3b70Ac4mg==
X-Received: by 2002:a17:90a:30aa:: with SMTP id h39mr1907044pjb.32.1564712219898;
        Thu, 01 Aug 2019 19:16:59 -0700 (PDT)
X-Received: by 2002:a17:90a:30aa:: with SMTP id h39mr1906994pjb.32.1564712218695;
        Thu, 01 Aug 2019 19:16:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712218; cv=none;
        d=google.com; s=arc-20160816;
        b=Jw7cUmTuec624gypanB6ghP0X6Ri7eGWHE+N8eSvGdIt2CBVeeNVKejW9JqncKDav1
         9naW70VzvAUcPrDdLI7BibAPi7SvL8/EnmYQ82XE74bqwE02Q+KfHgA886iMzvSZI9fX
         fBHth1fjNjFv9MEBmxGtJ4nf1pj8XLkmSnt3mtoNbh4hzWnAjBhLfltReYOfF9uz98a1
         Uq1KB4WXC08NPWhq5VjlG8iuQ4EMCHJetwNeqETSGKeAW0teMfosA3BsuX+9R5FJ1Gfp
         tIJ9ULxTB0vzZtUYZve92HAbklljCx/mejFWrLpeKlPyYVs9loaxMzBMdApk8k+jzjFv
         D8Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=3GzlMAdD/Fj4tpT1z/PK8Fr3raamoGX6ZwkHP2yb6K8=;
        b=Zwp+/YEgdLteHrh6PDe80uYEGfvLDPEIGcchofBD3zz3RgvjGZN7vP289ZBj9CYuUQ
         gTP1PsynSwlmhSEF3b9E2dOkMrqAQl9uEUBT/izBnzRmVZfBG/d9bHfi5e02S6COS7I5
         JHo8yRJWIgZZQ+XBz6iehIrkfOvD0jBYx2ORfVHvU+Qcs4OPsHL4YPxjAb8lNdcMNnlU
         fLhgPbiUr2uW+sin29CMBSKUPJbxTlRyQEOyMOdQi5d3VIzwzfINBdV25lT+AEaQfwFS
         AwApfP3JzFq3FYvHoI39FLcEIkIu2o3bgiIgcV5JUlradJ4rxas2M4t8l27SALy6Sbag
         Ubhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pAxzsc9v;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12sor38864087pgj.57.2019.08.01.19.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:16:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pAxzsc9v;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3GzlMAdD/Fj4tpT1z/PK8Fr3raamoGX6ZwkHP2yb6K8=;
        b=pAxzsc9vmHAK9ZK89AacBmqXQvuHXeShpu27WlEkAV6xBcEz/H1GAWLFbWBo+u7caH
         KIqDnTL+IS2r069Sqit6niTwIVD3yHwM2oL4UXxooa0ZG6T9kc1SZGdEzbmbTAJoZkzv
         Zbj81BMMiMsLujqrLP+vNRoPoAfxuyhBIJfz/EZgUl0FsiQZK3MgWkswQuDuhoaZBO9G
         KrSO58P9Rr9KxqN5N1BphpFtggyeHWY4ZqA08b5SYu2LL+896Hx8WIi0vBM/z3/TtXKP
         sQF/9gkVaL/sxZPp1Zgqo9a2gtCNNW4Q0F26WcstDN/wMJyWuPSmF5s5FUO43iGXa+xl
         t4bA==
X-Google-Smtp-Source: APXvYqzWsTlsiBNw6waYjgVc0NeqKYlyVqx46uMvNCwkUysDnG1IH1bMSSj1oKU/Y8CdBrk8llU2wQ==
X-Received: by 2002:a63:dd16:: with SMTP id t22mr90672497pgg.140.1564712218248;
        Thu, 01 Aug 2019 19:16:58 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id p187sm118200292pfg.89.2019.08.01.19.16.56
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:16:57 -0700 (PDT)
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
Date: Thu,  1 Aug 2019 19:16:19 -0700
Message-Id: <20190802021653.4882-1-jhubbard@nvidia.com>
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

