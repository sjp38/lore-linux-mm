Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AABACC76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 521D52199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VOdsVprS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 521D52199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A63D6B0003; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888838E0005; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71D648E0001; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2C06B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:30:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d3so22851690pgc.9
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 21:30:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=JVt6ZsruZdEjCeuPEiZoevmx4LJB3+Wj53DW9JaZ1Yk=;
        b=tszOxM2hK5vpEyDjf9bagqggYyQJhr1Tg+xJYWqN4PziiBzp8oxgHjULQJKWOuw+XB
         9zdDXODIhN73U4CMyz3WF8w/5vyXnfa2yWB9sDPVOFHfzHMw7pi/w4fEgYFerozFTkw/
         Olqy9L9JlilsV0eCDz+RkkLEvW8zl3OQ1Uxc8MDnl4VULeE3fowru8fDCozESVd0pJoj
         V8javXsn1IKszPN9x+N18DA9t3gcdDSuBCoBooewvZVYzl863vHMqPHQOGSqU5wqmBdH
         R0MCeLy848upbwTWuCOeEAN9X80s7XL9NQb57Ju9XDyZzTlPZWVWnKbU6GhVyji4q1pL
         50+Q==
X-Gm-Message-State: APjAAAUNut+M6MxFIj8iX5wDF/WqSW0JaNU0+fPPJDy2eDD2DyfhmBTj
	3u87ZEY+M+4AuK7nj6VcCUrhIKIJAwL/ckvygrkO3N5F7Au+T+1x4IiYPkBGBZcv6A8lecRLvIb
	ETf/jo5hbqn6yRQQtq8re6uO8puJexn8babhvXgWfSJTb6AeTb8Rh7gnVLgC08K1Q/A==
X-Received: by 2002:a17:902:d715:: with SMTP id w21mr33983955ply.261.1563769817778;
        Sun, 21 Jul 2019 21:30:17 -0700 (PDT)
X-Received: by 2002:a17:902:d715:: with SMTP id w21mr33983814ply.261.1563769816068;
        Sun, 21 Jul 2019 21:30:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563769816; cv=none;
        d=google.com; s=arc-20160816;
        b=cKHPSTzpnCp+77XYYWKSj6CX1PM3ZDRDopRfZhfHrnoSiStwhMYLC8biUjQzVc0b+9
         NHkOWpdsu8O78xUzhT2vSJerXnBJ8mkVo/JrAHVCukLE6iWxn1yjZU0OOz1YQNudKeLD
         fCy348Eo5PZGzJLbh1SvLF9VBjloAJjeN6LM9yJsS87fMFA8AvcF5KzH91SEUyBzQU25
         6Aqn7AkY0fbkVT8mZ3xe1ajl9fQA7+4zs7x18RDEndq77CtcpS2c2DzpO6CLduX4YVNK
         UCY6B6SDk8akAZOcmUgqowbQQ9h6sdZZpqhVj7l4e3TNyeF8TWLfryj3LUhNpT0U7E9w
         4h3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=JVt6ZsruZdEjCeuPEiZoevmx4LJB3+Wj53DW9JaZ1Yk=;
        b=Y3C5QXftHeiDU5dhaYz4L0Du554C+ctL7KbYBqwDDb2JpGOdrUgoDHX04xgMAmqhY1
         +NzG/NaQPBxQg4/8BBX//s34VyYUROs8595+3cEPgqohLOYYi0yZjuS7v4ZefkKOywaq
         DrOVKoF3K736jR2rmPV1tcQ9I0caCq0tsSmJeMdzeIeqCcMQx4hQf8aoPkVHFvAh5p53
         4P4yA6u/tgV0eir9jhP9g87+GaJ8iOtQ0jo2QCKdsTzyfAACe65ERN3qc2d8CWLSFunX
         re8MiSt5pl2DaQVnbONVgPEnAoI1r6gp/DCIjIz8MYHXiKHdTSHIQ9fkAb04tJdhQ0v5
         UYUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VOdsVprS;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor47704042pjc.24.2019.07.21.21.30.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 21:30:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VOdsVprS;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=JVt6ZsruZdEjCeuPEiZoevmx4LJB3+Wj53DW9JaZ1Yk=;
        b=VOdsVprSu9cGW1iqrmfPQX3xmYU5Z1o9cHF6pOzbJltiYhuYCge33pdD6CwMEXjvNM
         sFi5J1se+WaXJ91/TKlPNrLGUHwxnpIw4qn7UAwShRFJ/W8Nr1RUSKFA7n+45aPr6x5C
         WXA+RxInAR0EH7vDnRS0n0aIDe479ShZenlcHSFgtmJCj4AKpuj0qM5VYVp+YAGkHdwE
         O4cIZ7alr6idAM7ATqKQj8tHNYN+A4KH9dTbPVf+Boq9vCTQQ+AaVmGwBppTWRbLCXxn
         GvquR0RX9Yva+IepmKTElD2ekCLJhgD/84GbCKePJ9GNR9JpwzZV3DJPl7z/yc4lJjwJ
         ABng==
X-Google-Smtp-Source: APXvYqztu+uwlucjHIzVmQ0L57MjZIIjZ2e8k8CcXoJiraVsvVA60l6ON4zhkWJGUUfJVOo89G9VTA==
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr74049775pjz.140.1563769815699;
        Sun, 21 Jul 2019 21:30:15 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id t96sm34285690pjb.1.2019.07.21.21.30.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 21:30:15 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 0/4] put_user_page: new put_user_page_dirty*() helpers
Date: Sun, 21 Jul 2019 21:30:09 -0700
Message-Id: <20190722043012.22945-1-jhubbard@nvidia.com>
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

Here is the first small batch of call site conversions for put_page()
to put_user_page().

This batch includes some, but not all of the places that benefit from the
two new put_user_page_dirty*() helper functions. (The ordering of call site
conversion patch submission makes it better to wait until later, to convert
the rest.)

There are about 50+ patches in my tree [1], and I'll be sending out the
remaining ones in a few more groups:

    * The block/bio related changes (Jerome mostly wrote those, but I've
      had to move stuff around extensively, and add a little code)

    * mm/ changes

    * other subsystem patches

    * an RFC that shows the current state of the tracking patch set. That
      can only be applied after all call sites are converted, but it's
      good to get an early look at it.

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

[1] https://github.com/johnhubbard/linux/tree/gup_dma_core

John Hubbard (4):
  drivers/gpu/drm/via: convert put_page() to put_user_page*()
  net/xdp: convert put_page() to put_user_page*()
  net/rds: convert put_page() to put_user_page*()
  gup: new put_user_page_dirty*() helpers

 drivers/gpu/drm/via/via_dmablit.c        |  5 +++--
 drivers/infiniband/core/umem.c           |  2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c |  2 +-
 include/linux/mm.h                       | 10 ++++++++++
 net/rds/info.c                           |  5 ++---
 net/rds/message.c                        |  2 +-
 net/rds/rdma.c                           | 15 +++++++--------
 net/xdp/xdp_umem.c                       |  3 +--
 8 files changed, 26 insertions(+), 18 deletions(-)

-- 
2.22.0

