Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 762BBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AB80222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AB80222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 654998E000E; Wed, 13 Feb 2019 18:05:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DA6B8E0001; Wed, 13 Feb 2019 18:05:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4554A8E000E; Wed, 13 Feb 2019 18:05:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 011B98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:05:14 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so3101669pfk.12
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:05:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zDjJmdDKCnuzGVI1ffFlBWx2EW92voMzbQIkfK9Rw3U=;
        b=b5OoYfkncUGh+7MQOXBmlouI8N9ncUpkqqRu3OVwIHZLTvbWmCwVHbacUp1CaTFixt
         PCz/kA7ySK3EQk+yzcdeND8nWh4Xy7lfxvpT8tRY1ON8oJOAsId3gwWALQSQXgjtSGcX
         O7d0AhV8JH1SGDJ6oW1U7/xwXvFeOH4oNXT9h3O7mEQYJ0UV3rujS2vi6/e3rwfB+Y2p
         lERemtDxDLqBRq2yus+4DU/inZUpkd8F10/VzEfbf8E/cJnQoJFjg7rEFdc4Mn5UdBU+
         gdfJ5oY+qQrS3LCVwggd9PbMJxakqInyYg2C16oyIbyp8aeI4uFYvcBwco0zBiKbc/NC
         Fn6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY5v/5LRP9J+fFDwyEK1kfmy1nMCFXrFjyhWz+1CjZEt2P0hUF6
	AlbAtZIHu4juPvJsqoWq11Scj8KPbIlGpeWMi71oVHnExuc8WaoPGMro9j2l+nzFyHOZ7pESqcN
	Fx0krDV4O+8Cqr52FFAYGvormQjUKr09OxbzMqoe9QGYqyq7NFwivrN77HK8X4dBO1g==
X-Received: by 2002:a17:902:e78e:: with SMTP id cp14mr708647plb.4.1550099114641;
        Wed, 13 Feb 2019 15:05:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZDLWR9TISgOPWFeaC+Eqz/PEv7PTGYDNlH1MlXnJmbRp3pha9Vsd0Xbm8dEKRP8R2yfeid
X-Received: by 2002:a17:902:e78e:: with SMTP id cp14mr708556plb.4.1550099113565;
        Wed, 13 Feb 2019 15:05:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099113; cv=none;
        d=google.com; s=arc-20160816;
        b=YoOIvikHahzyAtrHY1aMAB0Cyik+LcSVsjpmKyr2eOKGy1pCJ/4k2HqY0uvNQWKND4
         HW4Qv+XEgnFccSezW9UupaVr6dTbR9ZwOaokuq9jHMXAyT+rkhQIfQh6Rd5CjTyrwyKj
         snwEzvxRGcDLiFTh1cAlb0ryki4DqCLzbsc9NuXrDUvY5mzWzWcfStS/Z0lmSLEuaoWJ
         nMRqAE7UQg+X2hHLA7hd8nP1osBaHG+/LHReOH42teh3cXDY+i+ocKOC5wdWRiJig7zT
         LFGo0vjXiU9/Jjjme7ytHH025mh22MOmBoP1d8smzmIfQEiDOkTJUNj77a3qit24kA/p
         wXyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zDjJmdDKCnuzGVI1ffFlBWx2EW92voMzbQIkfK9Rw3U=;
        b=Z1BAyLQdu77j9ZeRK1WvbOvXGmIx5CH4xNMO1KcprYrtwpFP2hvX76YBUhn4MnpP+o
         iVRZzfSXGRwt/hcktC5a6j9u86z/dloFllSWNU51iAOlmtn+ISLVV0q5v2HeACz1y7iY
         1Op063ITm9F7fAOWecHX3xL+j8NCAZYePVJq2nJeKiQf+KE8Uf4SgmLa7/MlIE3dXk9z
         NQRMaa3OBYkGb1Gwbl8cWX+QPAieeHYlEoUA6NdPsis/cnkN6Yrh4E9uQMnsEdAJKPyO
         9Sr1BO6x71fNhUymXd83tTW/kcJll7J0rBcFNrJo1y8Z8m1dFJAg/cWP57yUrGVXY2MT
         C8Ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 3si599378pli.417.2019.02.13.15.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 15:05:13 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 15:05:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="138415564"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 13 Feb 2019 15:05:10 -0800
From: ira.weiny@intel.com
To: linux-mips@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org,
	linux-mm@kvack.org,
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Cc: Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	David Hildenbrand <david@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Joerg Roedel <joro@8bytes.org>,
	Wu Hao <hao.wu@intel.com>,
	Alan Tull <atull@kernel.org>,
	Moritz Fischer <mdf@kernel.org>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	=?UTF-8?q?Kai=20M=C3=A4kisara?= <Kai.Makisara@kolumbus.fi>,
	"James E.J. Bottomley" <jejb@linux.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Rob Springer <rspringer@google.com>,
	Todd Poynor <toddpoynor@google.com>,
	Ben Chan <benchan@chromium.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Martin Brandenburg <martin@omnibond.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH V2 0/7] Add FOLL_LONGTERM to GUP fast and use it
Date: Wed, 13 Feb 2019 15:04:48 -0800
Message-Id: <20190213230455.5605-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190211201643.7599-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

NOTE: This series depends on my clean up patch to remove the write parameter
from gup_fast_permitted()[1]

HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
advantages.  These pages can be held for a significant time.  But
get_user_pages_fast() does not protect against mapping of FS DAX pages.

Introduce FOLL_LONGTERM and use this flag in get_user_pages_fast() which
retains the performance while also adding the FS DAX checks.  XDP has also
shown interest in using this functionality.[2]

In addition we change get_user_pages() to use the new FOLL_LONGTERM flag and
remove the specialized get_user_pages_longterm call.

[1] https://lkml.org/lkml/2019/2/11/237
[2] https://lkml.org/lkml/2019/2/11/1789

Ira Weiny (7):
  mm/gup: Replace get_user_pages_longterm() with FOLL_LONGTERM
  mm/gup: Change write parameter to flags in fast walk
  mm/gup: Change GUP fast to use flags rather than a write 'bool'
  mm/gup: Add FOLL_LONGTERM capability to GUP fast
  IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
  IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
  IB/mthca: Use the new FOLL_LONGTERM flag to get_user_pages_fast()

 arch/mips/mm/gup.c                          |  11 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c         |   4 +-
 arch/powerpc/kvm/e500_mmu.c                 |   2 +-
 arch/powerpc/mm/mmu_context_iommu.c         |   4 +-
 arch/s390/kvm/interrupt.c                   |   2 +-
 arch/s390/mm/gup.c                          |  12 +-
 arch/sh/mm/gup.c                            |  11 +-
 arch/sparc/mm/gup.c                         |   9 +-
 arch/x86/kvm/paging_tmpl.h                  |   2 +-
 arch/x86/kvm/svm.c                          |   2 +-
 drivers/fpga/dfl-afu-dma-region.c           |   2 +-
 drivers/gpu/drm/via/via_dmablit.c           |   3 +-
 drivers/infiniband/core/umem.c              |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c     |   5 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c |   3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  |   8 +-
 drivers/infiniband/hw/qib/qib_user_sdma.c   |   2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |   9 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c   |   6 +-
 drivers/misc/genwqe/card_utils.c            |   2 +-
 drivers/misc/vmw_vmci/vmci_host.c           |   2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c     |   6 +-
 drivers/platform/goldfish/goldfish_pipe.c   |   3 +-
 drivers/rapidio/devices/rio_mport_cdev.c    |   4 +-
 drivers/sbus/char/oradax.c                  |   2 +-
 drivers/scsi/st.c                           |   3 +-
 drivers/staging/gasket/gasket_page_table.c  |   4 +-
 drivers/tee/tee_shm.c                       |   2 +-
 drivers/vfio/vfio_iommu_spapr_tce.c         |   3 +-
 drivers/vfio/vfio_iommu_type1.c             |   3 +-
 drivers/vhost/vhost.c                       |   2 +-
 drivers/video/fbdev/pvr2fb.c                |   2 +-
 drivers/virt/fsl_hypervisor.c               |   2 +-
 drivers/xen/gntdev.c                        |   2 +-
 fs/orangefs/orangefs-bufmap.c               |   2 +-
 include/linux/mm.h                          |  17 +-
 kernel/futex.c                              |   2 +-
 lib/iov_iter.c                              |   7 +-
 mm/gup.c                                    | 220 ++++++++++++--------
 mm/gup_benchmark.c                          |   5 +-
 mm/util.c                                   |   8 +-
 net/ceph/pagevec.c                          |   2 +-
 net/rds/info.c                              |   2 +-
 net/rds/rdma.c                              |   3 +-
 44 files changed, 232 insertions(+), 180 deletions(-)

-- 
2.20.1

