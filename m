Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDFA9C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:32:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A08422146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:32:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A08422146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334EB6B0271; Mon, 27 May 2019 06:32:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2971D6B0273; Mon, 27 May 2019 06:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1105D6B0274; Mon, 27 May 2019 06:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B02F96B0271
	for <linux-mm@kvack.org>; Mon, 27 May 2019 06:32:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so27401153edr.18
        for <linux-mm@kvack.org>; Mon, 27 May 2019 03:32:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=85jYBj5PrQroZXLJZVx54g7mT2EDKdxV/uZBxsrFsL0=;
        b=eVpfX4ltH2Wgae73/cEKkD1HT9kCyhNE16s4DNrqY79Z2cuIPOlewZhv18tbPQHt1u
         A91nH06tmpmLQ1wMUEzMvYJhrzInOkBFU53KHEv7aTQragZPmIVwLAM5P6zP50sRHyPU
         g90yoQlBMZNckncHgEMhc9CM3bsqhbDeMx9ZB5lrgs/j72PTUC6qgcsGyxXi9i0kWrKz
         VjXA9QH7Ygwc/anhLl1ATLnAu3ghxqcSAJxYU3dDYIqQ6f8nBhvPAKw6KaRkWHoXjF2F
         kpZqOhIGbcOHWF4pc8wZavBGgnmNCqEhOFN5fcD2a2Ul84wcRdHwKN2zyj1/aRgERi2l
         Fb7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAXbKTpAYrSej/1gi2mIvORPbnGJznvlFLIN+THVnWLVQy10Jai0
	PgBn/HPzVRln90cS71K6i5pg/fS9yVKAeyJfwMVz7XjvbOwakpYdEBY9VHbRLwafephtRCjSzmX
	FNZHVKh+a5jzXhXsDlqzHFYGvSDpEzdqvVrAVg9a/S881HarRoQOWFkDllLhhqfYsCg==
X-Received: by 2002:a50:b062:: with SMTP id i89mr123357466edd.85.1558953134191;
        Mon, 27 May 2019 03:32:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxICbh3zChU4IZzQk57TSXF+0m7S5dWWn8Sa/Cr2Nb6MrXPe2uXx7xzHq+iVO9klWky+4SB
X-Received: by 2002:a50:b062:: with SMTP id i89mr123357397edd.85.1558953133339;
        Mon, 27 May 2019 03:32:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558953133; cv=none;
        d=google.com; s=arc-20160816;
        b=BWYTimA3KhwFCCQxNooPwfPmU0w/zW8+ySWDlbkfHWzEx+tZbVuNiE3J4Sj7DiYHBD
         WOku8g4QTNel48y/1sj2hQejuLSyJEY9yHndAOngwoXHGd5kXfu4K0m2+4XSxSkVfVsq
         Pz6MmXSJKZ0apeDvmQUJQZPFkzXGfVtTkZn3MM+EZdPYyYd4xEVJ+z++gHUQP0pwHzqA
         aix9Hj7TstgKnien6ftxnXLQ5riOI7xb8LUipvi5o7Y1/xTOH0Yjyd4nrG2sxAFaSkL9
         rNlE58FDT0feeAkX45m0/iLsarI8teaFrMGM2zyKgmagLTDFPFQlRCtnJOk87wKy2Qla
         9sqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=85jYBj5PrQroZXLJZVx54g7mT2EDKdxV/uZBxsrFsL0=;
        b=ONF6GB0ozrgSh2VPG0FCIXPoe58tIJUf5tzmIgHuo6uXmXBSBfoeGjjpt+X32Lr89E
         9SN3GcnamgaAuKrzu4eM8Hpwx1BSRH07P/gOB1ua8FDlTcG54nCVgO0XJOShpz+GYt6Q
         /mcV6UlliHQQBmIKHqFBrmxbl1kNiUWUGqwhna10mKTUu1M2mYNaNZ6c4qMjBaVn1y5I
         ICCAtYBwN5DzQt2M++mwWifINX6rNa5qbhHoWsUhkuLW84LtYPOvdqlwjGEYnDYJpcnq
         z+2xbWnLvZ2V4fwfAZoJAc3wLN03ortnG+kLeMxM76LufUAx9TQKqbOYbTZUz4xBq7Ky
         u1KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v5si6965441eje.348.2019.05.27.03.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 03:32:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4502AAE27;
	Mon, 27 May 2019 10:32:12 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-erofs@lists.ozlabs.org,
	devel@driverdev.osuosl.org,
	linux-fsdevel@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	xen-devel@lists.xenproject.org,
	Gao Xiang <gaoxiang25@huawei.com>,
	Chao Yu <yuchao0@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>,
	David Sterba <dsterba@suse.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	ocfs2-devel@oss.oracle.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 0/3] remove tmem and code depending on it
Date: Mon, 27 May 2019 12:32:04 +0200
Message-Id: <20190527103207.13287-1-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Tmem has been an experimental Xen feature which has been dropped
recently due to security problems and lack of maintainership.

So it is time now to drop it in Linux kernel, too.

Juergen Gross (3):
  xen: remove tmem driver
  mm: remove cleancache.c
  mm: remove tmem specifics from frontswap

 Documentation/admin-guide/kernel-parameters.txt |  21 -
 Documentation/vm/cleancache.rst                 | 296 ------------
 Documentation/vm/frontswap.rst                  |  27 +-
 Documentation/vm/index.rst                      |   1 -
 MAINTAINERS                                     |   7 -
 drivers/staging/erofs/data.c                    |   6 -
 drivers/staging/erofs/internal.h                |   1 -
 drivers/xen/Kconfig                             |  23 -
 drivers/xen/Makefile                            |   2 -
 drivers/xen/tmem.c                              | 419 -----------------
 drivers/xen/xen-balloon.c                       |   2 -
 drivers/xen/xen-selfballoon.c                   | 579 ------------------------
 fs/block_dev.c                                  |   5 -
 fs/btrfs/extent_io.c                            |   9 -
 fs/btrfs/super.c                                |   2 -
 fs/ext4/readpage.c                              |   6 -
 fs/ext4/super.c                                 |   2 -
 fs/f2fs/data.c                                  |   3 +-
 fs/mpage.c                                      |   7 -
 fs/ocfs2/super.c                                |   2 -
 fs/super.c                                      |   3 -
 include/linux/cleancache.h                      | 124 -----
 include/linux/frontswap.h                       |   5 -
 include/linux/fs.h                              |   5 -
 include/xen/balloon.h                           |   8 -
 include/xen/tmem.h                              |  18 -
 mm/Kconfig                                      |  38 +-
 mm/Makefile                                     |   1 -
 mm/cleancache.c                                 | 317 -------------
 mm/filemap.c                                    |  11 -
 mm/frontswap.c                                  | 156 +------
 mm/truncate.c                                   |  15 +-
 32 files changed, 17 insertions(+), 2104 deletions(-)
 delete mode 100644 Documentation/vm/cleancache.rst
 delete mode 100644 drivers/xen/tmem.c
 delete mode 100644 drivers/xen/xen-selfballoon.c
 delete mode 100644 include/linux/cleancache.h
 delete mode 100644 include/xen/tmem.h
 delete mode 100644 mm/cleancache.c

-- 
2.16.4

