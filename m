Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77B61C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:30:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3417521848
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:30:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3417521848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB55B8E0003; Wed, 20 Feb 2019 00:30:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8ABE8E0002; Wed, 20 Feb 2019 00:30:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97A998E0003; Wed, 20 Feb 2019 00:30:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1EB8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:30:51 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v16so16610035plo.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:30:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=2ZpTCwRzqlFeaNIz1GWMrPpbTW4msiUVmURzvofW+UI=;
        b=N8USTaKU/KFuT+NcFE9isE1eR5531OHiWuQ/2KgKY/9f90HMqr7Up6cjuo557FoXBW
         VWXOzNXCrcff+kclcIm0khzjjmHlrh41y+ztI1/Wak9Oaylzffdz6EpyLyAkU1Nf2OwW
         4Pbr5HS+Ugs6JAUNXS7ANI0yBN0/EYjeOkYpI8FVkjCfC7AVuDfdZMzTXLnQHqRHVYF/
         qGBOkB0qgVDuKvfWd8CXtCHET2hSqPQC3UI+3kepb3iLtCkZMqkYZoyTsgS1/lZpJEm3
         7o5V0wDGOacEFnywZMghGic1GHHsCYYJUyWugeT51eLDzi07NvjmeNiKHnXJWHWcoWzz
         3mKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ7MYubMaQscvieSv7Apf4MgC0wA1WbMqNgfoofFcgmgk4PZXM8
	krEI32PsFy6U61r1T3w5O/YqDQs4jp8oPKIelOQc+udXX1OVySOKOun1gb1pF4gHjHWx3GRV3Ea
	10L8OMslw0bb/ue11CwkebSpHHeRaDDCsxF5ZsvyP2uLQ3f6d/AANF9pxhOtgJxSt+g==
X-Received: by 2002:a63:ea52:: with SMTP id l18mr27641516pgk.317.1550640650723;
        Tue, 19 Feb 2019 21:30:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFZl7VuAegGRWobtZlhXVo2/PJ1Hff57EvPF1IWqH0Edtac5RCmd0+Z3cpe9Z7JLvHr1lz
X-Received: by 2002:a63:ea52:: with SMTP id l18mr27641450pgk.317.1550640649621;
        Tue, 19 Feb 2019 21:30:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550640649; cv=none;
        d=google.com; s=arc-20160816;
        b=j4JkI12Q1Ae7to9rcTH/RxgOxY7FNr8+c0CZJX2ZmhWXv2KN927VIsYBSSB4FPqEcz
         /udh9vNhj4o0bGJoIm0ZfisqlDdPvcaDwRLlmQGxG+wlGDVu/I4cJ6RcMfWl2DgZkVFV
         X3+IWYng/4D7uurw6bbq/ZPBmmk5qekHIM2RNxKP8nHPPe4yuMl1qtUPA7va8yOG2P9y
         vAZfrDUWswHTqP9uPLDAPGAjqbl0XAzqe1pkL8oh77Irc+hrYkbxKkkN7yfj+fE+6Mqo
         /hMM+Sva4e78phEJjqraicJWzwe0f4hsPZm5Grf8qsoV9qI9+THHAcijaMVs61oSkp2l
         zpWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=2ZpTCwRzqlFeaNIz1GWMrPpbTW4msiUVmURzvofW+UI=;
        b=chCxA8qES90azCSKarpS+1cLXCYBa49zty470veBLyN1biRg3xpLgdHYjYJWVtUsyG
         wfpuqScsCCr/vWoQ9JGiXHx0yqRowPbpvDfL2tCaIISIhhf6UzVyH8D9YfOb1Q9WllcG
         CBN/33BqfzSf4ekVs+vkFdyPxff2/gKn834Agx9sKzoqof4Z0XE5xI7ZJaXFdOkDJRfI
         u+md7Z61VuqmdNqoT4C5CKGZtNwg8ATyHE9R2NA5/XewyjSnjTcIa9///jEzWaYgowO2
         xUY9Vcz8/PCc7cSd99NZnzRfq+ADuf+MkGSFXItoguolin9ihquobCYk0LUPQ0UQybbO
         K57Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id t3si6328884plq.430.2019.02.19.21.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 21:30:49 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Feb 2019 21:30:49 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,388,1544515200"; 
   d="scan'208";a="144924899"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 19 Feb 2019 21:30:48 -0800
From: ira.weiny@intel.com
To: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
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
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Subject: [RESEND PATCH 0/7] Add FOLL_LONGTERM to GUP fast and use it
Date: Tue, 19 Feb 2019 21:30:33 -0800
Message-Id: <20190220053040.10831-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Resending these as I had only 1 minor comment which I believe we have covered
in this series.  I was anticipating these going through the mm tree as they
depend on a cleanup patch there and the IB changes are very minor.  But they
could just as well go through the IB tree.

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

