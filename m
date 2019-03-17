Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ED05C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31BF5214AF
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31BF5214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87EA66B0008; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 808696B000C; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A8236B000A; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 255716B0007
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f19so17507445pfd.17
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=5Q5aD1CqHSfDDKP5YVIrJjq6e15QngbCkOT4SQnVSpM=;
        b=RANvC2k9b8OYOYx0IVmpWH+8pjg6c2oXanpkzD1Y6nfTlpO+PRR6l1qyrg65qFPMO+
         ot3cGd/Q5pEnBRB4ihoLRpBdZxhO7Kqkxu7N5/JMwoHz6H6mgFgnvLyaZNWJ0K5far+t
         m+mjTO18yPg3zmW2UGXYA43A8bfPpD4gTaXxn3KexIVDPbSbvW1wBR3G2fkthU80erti
         kgXHlw5O2Kos6eObDQTDoWOR4Za4PAloCsV3Nw5pUiQWMX43ks+sZ8q4lHibgye1UM/2
         WGG0cHAnBCvwthERdLeCGSwnshZ0ptykwuKLZ+cfQ9ZkIj6bK1PAPvdjKNhBpM7I/qPq
         JrzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXIGF9sc+O/wdQokBjJRKXQnts1bYe8dusT4BgZ0VKCGCy3stxu
	VJjDGMNamblH2mHiKQpxvyWdoP67YhmSDzFW+AScMk56pa0y7Hc0FSNHRX4EECbygUYREh4fepm
	BAY+HTwCV5HaLmRnwhA1POkZiIn3D6h2altFSUBzKvHNCAZrgZceDvTDDKv7VpdpNpQ==
X-Received: by 2002:aa7:8d43:: with SMTP id s3mr16638712pfe.118.1552876565735;
        Sun, 17 Mar 2019 19:36:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7wBP2CNJWnOecJk0ig+Lf9JnL+7+PuCavbdE8FonQzDn7eHVVXHE1w3/0iW+qWARrpYHr
X-Received: by 2002:aa7:8d43:: with SMTP id s3mr16638651pfe.118.1552876564588;
        Sun, 17 Mar 2019 19:36:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552876564; cv=none;
        d=google.com; s=arc-20160816;
        b=ukyDyows5qRVsxVa6FnbWKTxziSaKFvaFScP8Ms5jtV9+VJhVVwiA98lhCIIR7ShnQ
         +ZGDLEPaydPNfd3UeS0jvgNsS5MFd/rsils+xk/54ZwKdOzr1X42/LyZhxBOfRgpF/3f
         n40yDdaH0ABcBwiS5e8ZY6/mF6+gOK4Y1jAkAjMl5NMdnYG5Xcv2LT7r4K3+33kfDrmf
         KhlhralE7ehHrHIPaCLzse7JTvAMefkCvC9RfOCcAjlWjOQafJht7+MeWU+hBgHZ9M5f
         NwJ6z9lz/NDVkNE+SEiyWjKlxKP/KpQM+OvH2K7OkNj8LrK5oS4xe8f/7um5vR0feNMF
         e1og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=5Q5aD1CqHSfDDKP5YVIrJjq6e15QngbCkOT4SQnVSpM=;
        b=PK2UVgeOIRFhuxlGJ9G+/eVZFp4XxB1+CGU2sKqKQG7RCN8+U2TYOgcq1g7nqOKTmE
         cmzeWVxLH83BtFmi7XSpv3wbXPPpOyvTCFG1yBEhL+BRLJp2XxBtC45r5yt1wHtwKtA7
         ioU7DtA//uw8/fhWnpvixZp4QeavI+meFMaVXx7BnUzZ1hosiF1B5VN+p3nOVBPC/hZ9
         ifkjDWoescPyYtymXaS2mHPmTkUNQB5hzaE9nSSn8zmenGdqnsu96h2IZQWjkBDM25SB
         v7/1bnoK2Aoq2CSKznHwhYNZauosdckid6WSiGaT65rJ8fvMTGjHBmHrVdt5+gxULQcE
         VHRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j71si8521384pfc.280.2019.03.17.19.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 19:36:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Mar 2019 19:36:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,491,1544515200"; 
   d="scan'208";a="155877408"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 17 Mar 2019 19:36:03 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
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
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [RESEND PATCH 0/7] Add FOLL_LONGTERM to GUP fast and use it
Date: Sun, 17 Mar 2019 11:34:31 -0700
Message-Id: <20190317183438.2057-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Resending after rebasing to the latest mm tree.

HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
advantages.  These pages can be held for a significant time.  But
get_user_pages_fast() does not protect against mapping FS DAX pages.

Introduce FOLL_LONGTERM and use this flag in get_user_pages_fast() which
retains the performance while also adding the FS DAX checks.  XDP has also
shown interest in using this functionality.[1]

In addition we change get_user_pages() to use the new FOLL_LONGTERM flag and
remove the specialized get_user_pages_longterm call.

[1] https://lkml.org/lkml/2019/2/11/1789

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
 arch/powerpc/mm/mmu_context_iommu.c         |   3 +-
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
 fs/io_uring.c                               |   5 +-
 fs/orangefs/orangefs-bufmap.c               |   2 +-
 include/linux/mm.h                          |  18 +-
 kernel/futex.c                              |   2 +-
 lib/iov_iter.c                              |   7 +-
 mm/gup.c                                    | 258 ++++++++++++--------
 mm/gup_benchmark.c                          |   5 +-
 mm/util.c                                   |   8 +-
 net/ceph/pagevec.c                          |   2 +-
 net/rds/info.c                              |   2 +-
 net/rds/rdma.c                              |   3 +-
 net/xdp/xdp_umem.c                          |   4 +-
 46 files changed, 262 insertions(+), 197 deletions(-)

-- 
2.20.1

