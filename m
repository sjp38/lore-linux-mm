Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6105C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E96D2080C
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="drt6EjFd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E96D2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40AD66B0006; Wed, 24 Jul 2019 00:25:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BE836B0007; Wed, 24 Jul 2019 00:25:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25C9E8E0002; Wed, 24 Jul 2019 00:25:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DEFB96B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so23338917plp.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=czbKIXOb/Go0XhMRs2MEN6VnTG6u3MuZundQHh6fuSE=;
        b=gKXrqrXE0S23u4OQOBf7G1HpXlVPlh6JkWVWwTLSPsgVM9Kbj8gHYz7QJ+Fab90I5q
         h0lQQsNHVCXtcWdE8qIhBkY2arhkbpisTTRtJnowzqt+b6QoHW42Y362jxA/QmiFAcfK
         cPFrS96oTBMEsjkTD6xn9z4b7TDt6FFDlJm9tyr93fgMVd1WRUcMXHCvYdMx1lHg1p+W
         SQm4WJ/SQuo4Ks3HcHnUWX0t2a5F8Qw6pc+ng78PPS3dF9g9QiDPZ3L9IcIxYnN3fm60
         md43lR5yznMJ+X8LneLgwq6hCxoY/8sHvL+LKbh8sBpYiE0MvuQ9Y+SXhGuq+kag2e/y
         yEUw==
X-Gm-Message-State: APjAAAWOYhrtKJma8AelaqfXMR3mW6Iow/Pw0nxfYPzQEo4dFIrjehy5
	nZVz2GfNIIAaZtWmC/j4BNDtJaQeSC7nTIbtcwvqflJnFnORyzOL7tuiG8FT9Yd+zRt2F+EOlrw
	eTEvZrNRGRF+fe795EahUqT5sGj+zhvB9zCCVVFLP3jSrCEBAMCUrspxzdAGhDysxcA==
X-Received: by 2002:aa7:818b:: with SMTP id g11mr9339826pfi.122.1563942322444;
        Tue, 23 Jul 2019 21:25:22 -0700 (PDT)
X-Received: by 2002:aa7:818b:: with SMTP id g11mr9339779pfi.122.1563942321661;
        Tue, 23 Jul 2019 21:25:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942321; cv=none;
        d=google.com; s=arc-20160816;
        b=AM0R8Rd7hyQ8GllAfDyOmHky/9SDHh82YWcFaiyDOPpUCixdolWmsZXnGwSz602p1i
         XXuBTEPL8xKF4sKHsbV3YqTOyixbD0bJ/BvVoMyDQd2ahEXSUotoFxTNJoW7CONWPBC1
         NXhZBhafIzqsN5s+ShzEJ9LvjE+w9qOBYT2WOt7qmeb05ie4tZIEv84kJjZdPLSn4O5J
         7ld6KbV1QtNVf1F3cpropbeSp9pE3gpPi2EYebFpXCgu5UAXeBvnFA3PUa3LcY40Gjpm
         xa+zl0zUqpPZVjHfdPVDh6NfUZ3Xk6zy1xD5xSsESmXoWcc+eKOHBMJoUCwIaVeKQma7
         GoQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=czbKIXOb/Go0XhMRs2MEN6VnTG6u3MuZundQHh6fuSE=;
        b=e3Mldel12NgTHPtLs85PtKuUjuMNWok4FcmWt+3KRA4Ngy0mup+6R42tWNDA+FOh+q
         TKYBoKUmYTSkO7v6MZTy3fOQK9QH1tsj/bKbQgYVuU39oPgR11vbaZiLohW6Ls3ZgLFB
         bbGEJzt6O+KIQ2vJoASO2roasBYMeLhQjsAUWW7b/ssok4nQyxWFkx3N/I+KIdOrk77W
         qw7ahC5bwv3SPBjXnSOyI7tcJ3WfLxSXG1Ujw+/NjDZbYO82pe6RHUbpU4R7BaXWYK+s
         7oeHq+/rd8mFxhcAbLqDYtoGpJ3Qx4IAZSC8lGYsAopGcwdna4CyVvVoVV2ZVGp8CGgo
         Tt2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=drt6EjFd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor2376348pgm.8.2019.07.23.21.25.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=drt6EjFd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=czbKIXOb/Go0XhMRs2MEN6VnTG6u3MuZundQHh6fuSE=;
        b=drt6EjFdosCAcMEHtdm6+Wwi0M6mSxOzFkxqawZr6IPXLSVzqb/W29XJdPWwpIC0hK
         6O36OujVLFyXEay6jApmdcKGKaFf8ZHrynwkSnL37TGZQHVi5dSIejM/BVPUxQ7VV65S
         fWBfNJcl5fT06CyStqADu0QhfKQgev+DV1jB/43XtDAQrRVBT4D8hAHyS32+/jE194Ee
         9IJK8BdynnPV24hoHobSOouQX3yA4+C8Ogba9Jjmu1EUBDg3exofJAkPMZ4BVkwyR1FN
         DpKTuGd8V6acalOBWqjEaikoQcAKX4Ix3w6DkaRL7W59P9w2XZ6f+kz4iv47D5f4dYHi
         ARbw==
X-Google-Smtp-Source: APXvYqwbbPiJvrG7YMdt1a1WYUqGY2Z5kAsIWFPe6nz2zmmLERZ6mi3tyMsrNzYm3HTPDg7yUokVfw==
X-Received: by 2002:a65:6288:: with SMTP id f8mr74189986pgv.292.1563942321242;
        Tue, 23 Jul 2019 21:25:21 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:20 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 00/12] block/bio, fs: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:06 -0700
Message-Id: <20190724042518.14363-1-jhubbard@nvidia.com>
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

This is mostly Jerome's work, converting the block/bio and related areas
to call put_user_page*() instead of put_page(). Because I've changed
Jerome's patches, in some cases significantly, I'd like to get his
feedback before we actually leave him listed as the author (he might
want to disown some or all of these).

I added a new patch, in order to make this work with Christoph Hellwig's
recent overhaul to bio_release_pages(): "block: bio_release_pages: use
flags arg instead of bool".

I've started the series with a patch that I've posted in another
series ("mm/gup: add make_dirty arg to put_user_pages_dirty_lock()"[1]),
because I'm not sure which of these will go in first, and this allows each
to stand alone.

Testing: not much beyond build and boot testing has been done yet. And
I'm not set up to even exercise all of it (especially the IB parts) at
run time.

Anyway, changes here are:

* Store, in the iov_iter, a "came from gup (get_user_pages)" parameter.
  Then, use the new iov_iter_get_pages_use_gup() to retrieve it when
  it is time to release the pages. That allows choosing between put_page()
  and put_user_page*().

* Pass in one more piece of information to bio_release_pages: a "from_gup"
  parameter. Similar use as above.

* Change the block layer, and several file systems, to use
  put_user_page*().

[1] https://lore.kernel.org/r/20190724012606.25844-2-jhubbard@nvidia.com
    And please note the correction email that I posted as a follow-up,
    if you're looking closely at that patch. :) The fixed version is
    included here.

John Hubbard (3):
  mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
  block: bio_release_pages: use flags arg instead of bool
  fs/ceph: fix a build warning: returning a value from void function

Jérôme Glisse (9):
  iov_iter: add helper to test if an iter would use GUP v2
  block: bio_release_pages: convert put_page() to put_user_page*()
  block_dev: convert put_page() to put_user_page*()
  fs/nfs: convert put_page() to put_user_page*()
  vhost-scsi: convert put_page() to put_user_page*()
  fs/cifs: convert put_page() to put_user_page*()
  fs/fuse: convert put_page() to put_user_page*()
  fs/ceph: convert put_page() to put_user_page*()
  9p/net: convert put_page() to put_user_page*()

 block/bio.c                                |  81 ++++++++++++---
 drivers/infiniband/core/umem.c             |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c    |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c |   5 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c   |   5 +-
 drivers/infiniband/sw/siw/siw_mem.c        |   8 +-
 drivers/vhost/scsi.c                       |  13 ++-
 fs/block_dev.c                             |  22 +++-
 fs/ceph/debugfs.c                          |   2 +-
 fs/ceph/file.c                             |  62 ++++++++---
 fs/cifs/cifsglob.h                         |   3 +
 fs/cifs/file.c                             |  22 +++-
 fs/cifs/misc.c                             |  19 +++-
 fs/direct-io.c                             |   2 +-
 fs/fuse/dev.c                              |  22 +++-
 fs/fuse/file.c                             |  53 +++++++---
 fs/nfs/direct.c                            |  10 +-
 include/linux/bio.h                        |  22 +++-
 include/linux/mm.h                         |   5 +-
 include/linux/uio.h                        |  11 ++
 mm/gup.c                                   | 115 +++++++++------------
 net/9p/trans_common.c                      |  14 ++-
 net/9p/trans_common.h                      |   3 +-
 net/9p/trans_virtio.c                      |  18 +++-
 24 files changed, 357 insertions(+), 170 deletions(-)

-- 
2.22.0

