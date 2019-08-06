Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C5F2C32751
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51B94214C6
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="B0RBkomh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51B94214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A57AF6B026A; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 800326B0266; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65A9A6B026C; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16EC76B0266
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l9so80223039qtu.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=0FF0tXIe7rc2zq4BQfqO1Tr1iiwuQDZe0G+/mYZhPb4=;
        b=Q+0zaYoGvM5c0esw6Mlkk2Hpw9c2ZSgG1lBUJgXBwroqtbTkGVfKB3BfpTZOXRE/K6
         0/B+u3sXxirpazEtZnCcJDRQOExZg0WlWDkBFNg0g/ijrJefPgcs4MxwFWNAIi6xghQ0
         ZmMYgE0W/uTGxcfW5MoKB4ijp5mf8KVz8kq3lkuVv0eoD33Wnz9ltzGs5XhAKQAFGHz1
         J+6VxQsCC8SUE1rCrePpqzw/jv2PxqjyNBJps/w2cxs50aLQw1xz6p13t95pvSxtwCZg
         lb1fXbd+xsHmkdlN0cL33ZNuJTDJXD0VycvDwSZ7b8Y+/FCCdYz60hEmhGDLoIR4cJn4
         wD+w==
X-Gm-Message-State: APjAAAV2/W7kHd/NP+6wtrHLeITZBUte5UVx5s5xqkMKaJwzbSZ0uIOw
	KH5gntMVYsstCgU9fRnC4oHnAswHGdOWy30peWeQPsburbWPqBdlOnle9resV+FjvibTPBVrZ95
	5I0shUgoKH+VQRDLoHTt8HyvzaW4ngzInIhodyZ7RfB51FWD9Ii5J+2aqC3YTs/PqZA==
X-Received: by 2002:a37:a116:: with SMTP id k22mr5644984qke.53.1565133379859;
        Tue, 06 Aug 2019 16:16:19 -0700 (PDT)
X-Received: by 2002:a37:a116:: with SMTP id k22mr5644936qke.53.1565133378995;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133378; cv=none;
        d=google.com; s=arc-20160816;
        b=DWoyhUGwJ18lkFbp428wbIMJPRQE9Kk7iHN4DjuO/9mPLBpGeue87tvF/7FVEZIBv+
         MYGaSIvzLXUaj5AOorDFw+B3P7/sunk7cH8+e1k5+wY7JvWJJRxfz81WGSjkCPru++Kz
         UgqeMOBiJNZx7/ACOzSkL0HZ5h3+b/p3z9wp2flNoazsRCCspUEU2cGRs6W0UgiunRJ2
         wpQEfPmiTToHMmitQhDNl3PvNPUhQ/ffNKR+SMhtfb2Am2EF+BnzSJps3uj4MQEoWRph
         S1akkuTz+DDwZu67ZfJsnETlYfHQLyNnZhhfgi1iNu6lWswpTzqq/xBeenE/BNm4Furp
         hNIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=0FF0tXIe7rc2zq4BQfqO1Tr1iiwuQDZe0G+/mYZhPb4=;
        b=C+NeXXOwt5L5tUa/l8Q1vrLwIKYxZaKjIyVVdwEjIROQqEbMR14pjnqJ56mQR62i24
         EEByqePw6fTVLwCcFmqqA4Swram27Q0qNLcHmGkXaEBQKQ+d2CVJUQs68yVbT7/NMDKD
         0z56iT7Q38HoRvs5SbCc4z6liNgiswGMEoNHAm2XzSgi78WM4j+vh8c5gydKUklJ3wXm
         +9a6BLGtH7TUQ96i4eOgdppvyba1CgA148emyMHxxJn3NoLTblx0A/8JR9E9YCntCBWY
         Us0MAvIRJESg1Qz34ospH17wIayPB2A6AHDpld5XQEVVO4g+4zYQnPYK39+xiOq2220j
         LVEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=B0RBkomh;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d46sor2346321qtc.69.2019.08.06.16.16.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=B0RBkomh;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=0FF0tXIe7rc2zq4BQfqO1Tr1iiwuQDZe0G+/mYZhPb4=;
        b=B0RBkomh8xhiu/KwJPirnADpsgmm80iyA8oyAeS7tjmLyr6+OYlG3sTHcQnHxrHuyg
         hrEV+59BPYDAolV+0C/Qm0JvE6OUmYPhPiU/hCiW2Im2VGOJ31mcwLL+A5qQ1rCZHNwb
         x+I+HX18fZ8WcbYwPofPsca2cfe1Dd0aGLylzfF8mtyBVAM+qXmK/+UgNQi+0EQzC0Kz
         oB9X6jiIokBPaNFinF6Ry/tAJjp1AH1v6xOfZIYHJxV9CiAgZfrkjAi5u5gvTirJtxfP
         ZI1nGkw+lv9ZBWXCB3lQbrDgT2UX0s56E7c4eY7X9nbudd1m6cqGwR2I36Jj2ZjMphM1
         s7aQ==
X-Google-Smtp-Source: APXvYqwaqbdf4QIvkKtMVoSEHzYJbTOhZ2bib6YyUfojcuKh8v466IsdF9eIG1S+OrEDo9cDhi4cNQ==
X-Received: by 2002:aed:37e7:: with SMTP id j94mr5361848qtb.75.1565133378614;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o21sm10387881qtc.63.2019.08.06.16.16.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gf-0006eA-Vd; Tue, 06 Aug 2019 20:16:13 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v3 hmm 00/11] Add mmu_notifier_get/put for managing mmu notifier registrations
Date: Tue,  6 Aug 2019 20:15:37 -0300
Message-Id: <20190806231548.25242-1-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

This series introduces a new registration flow for mmu_notifiers based on
the idea that the user would like to get a single refcounted piece of
memory for a mm, keyed to its use.

For instance many users of mmu_notifiers use an interval tree or similar
to dispatch notifications to some object. There are many objects but only
one notifier subscription per mm holding the tree.

Of the 12 places that call mmu_notifier_register:
 - 7 are maintaining some kind of obvious mapping of mm_struct to
   mmu_notifier registration, ie in some linked list or hash table. Of
   the 7 this series converts 4 (gru, hmm, RDMA, radeon)

 - 3 (hfi1, gntdev, vhost) are registering multiple notifiers, but each
   one immediately does some VA range filtering, ie with an interval tree.
   These would be better with a global subsystem-wide range filter and
   could convert to this API.

 - 2 (kvm, amd_iommu) are deliberately using a single mm at a time, and
   really can't use this API. One of the intel-svm's modes is also in this
   list

The 3/7 unconverted drivers are:
 - intel-svm
   This driver tracks mm's in a global linked list 'global_svm_list'
   and would benefit from this API.

   Its flow is a bit complex, since it also wants a set of non-shared
   notifiers.

 - i915_gem_usrptr
   This driver tracks mm's in a per-device hash
   table (dev_priv->mm_structs), but only has an optional use of
   mmu_notifiers.  Since it still seems to need the hash table it is
   difficult to convert.

 - amdkfd/kfd_process
   This driver is using a global SRCU hash table to track mm's

   The control flow here is very complicated and the driver is relying on
   this hash table to be fast on the ioctl syscall path.

   It would definitely benefit, but only if the ioctl path didn't need to
   do the search so often.

This series is already entangled with patches in the hmm & RDMA tree and
will require some git topic branches for the RDMA ODP stuff. I intend for
it to go through the hmm tree.

There is a git version here:

https://github.com/jgunthorpe/linux/commits/mmu_notifier

Which has the required pre-patches for the RDMA ODP conversion that are
still being reviewed.

Jason Gunthorpe (11):
  mm/mmu_notifiers: hoist do_mmu_notifier_register down_write to the
    caller
  mm/mmu_notifiers: do not speculatively allocate a mmu_notifier_mm
  mm/mmu_notifiers: add a get/put scheme for the registration
  misc/sgi-gru: use mmu_notifier_get/put for struct gru_mm_struct
  hmm: use mmu_notifier_get/put for 'struct hmm'
  RDMA/odp: use mmu_notifier_get/put for 'struct ib_ucontext_per_mm'
  RDMA/odp: remove ib_ucontext from ib_umem
  drm/radeon: use mmu_notifier_get/put for struct radeon_mn
  drm/amdkfd: fix a use after free race with mmu_notifer unregister
  drm/amdkfd: use mmu_notifier_put
  mm/mmu_notifiers: remove unregister_no_release

 drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c  |   1 +
 drivers/gpu/drm/amd/amdkfd/kfd_priv.h    |   3 -
 drivers/gpu/drm/amd/amdkfd/kfd_process.c |  88 ++++-----
 drivers/gpu/drm/nouveau/nouveau_drm.c    |   3 +
 drivers/gpu/drm/radeon/radeon.h          |   3 -
 drivers/gpu/drm/radeon/radeon_device.c   |   2 -
 drivers/gpu/drm/radeon/radeon_drv.c      |   2 +
 drivers/gpu/drm/radeon/radeon_mn.c       | 157 ++++------------
 drivers/infiniband/core/umem.c           |   4 +-
 drivers/infiniband/core/umem_odp.c       | 183 ++++++------------
 drivers/infiniband/core/uverbs_cmd.c     |   3 -
 drivers/infiniband/core/uverbs_main.c    |   1 +
 drivers/infiniband/hw/mlx5/main.c        |   5 -
 drivers/misc/sgi-gru/grufile.c           |   1 +
 drivers/misc/sgi-gru/grutables.h         |   2 -
 drivers/misc/sgi-gru/grutlbpurge.c       |  84 +++------
 include/linux/hmm.h                      |  12 +-
 include/linux/mm_types.h                 |   6 -
 include/linux/mmu_notifier.h             |  40 +++-
 include/rdma/ib_umem.h                   |   2 +-
 include/rdma/ib_umem_odp.h               |  10 +-
 include/rdma/ib_verbs.h                  |   3 -
 kernel/fork.c                            |   1 -
 mm/hmm.c                                 | 121 +++---------
 mm/mmu_notifier.c                        | 230 +++++++++++++++++------
 25 files changed, 408 insertions(+), 559 deletions(-)

-- 
2.22.0

