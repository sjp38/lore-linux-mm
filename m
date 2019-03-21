Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42C71C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:02:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BA552175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:02:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BA552175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B17586B0003; Thu, 21 Mar 2019 16:02:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9F796B0006; Thu, 21 Mar 2019 16:02:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 940B66B0007; Thu, 21 Mar 2019 16:02:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 560C66B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:02:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so6420017pgf.22
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:02:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=eCiD5gjvW3NVWsHXwQGeP5ZKsJarbf2O5NIyqu7kJU0=;
        b=Zj1TMj4gnZW9JOu4uqBgCNvShQQhxInpMZB48Wl+rzD/ESAJG27ceo/vwN11bxsyVJ
         Xel+EylbDpAO22wxPTbBB9ecmgBckEr299nFtEgecDMy8Zn0mIAwMpKxEXSGpNO1c1kd
         0ub4HxjqRwRGbR5nfn03e8ioSyvZ8KI1hGeMj4dPIaPCBBTVDhe+NGhC1PnWrSKgVnJH
         cgmR69MM04r16kPUmqeyTFemopduMOCu6iWvap8QpEi0qkCjhx6dHfVIDPmfnKg9k1D3
         UPcQvJ6bpW926yGl1S+KKF342K72W5uW9NBUezOKdGVX0ghTI34Pao5q1PNybzcyI+dI
         p/mA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUpECHa929XFwruKNzcx4xkWYhvaQIds0pAe3zB+o6A+VYJ1XYS
	vclmDiDSHUwZk4uqjHN0SC6gqXoMHB/HXtCCi49X0k/7vFc4YscSKxO391BFSVXYmC7mr8aqujP
	+n3h4kSatlkUoOfhTnyW6xEBJZYpPxae8WOIzqZWUwmAQGPYHk5i/6TFstmR3CFnQcA==
X-Received: by 2002:a65:5c01:: with SMTP id u1mr5088144pgr.197.1553198577873;
        Thu, 21 Mar 2019 13:02:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuIMxUzJqHqWDQd8cVvBsmHljqTiT8IgxO67bAvH83ivpUsy5CJ71dNgjkA0+D4WePAZsJ
X-Received: by 2002:a65:5c01:: with SMTP id u1mr5088067pgr.197.1553198576869;
        Thu, 21 Mar 2019 13:02:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553198576; cv=none;
        d=google.com; s=arc-20160816;
        b=fFkJWXKc0gesQu8/Ym5D5bgYvDTVt1TiAmwjN+pd2BR+nFk57INa6ipN4mrgjYmsUT
         OGpM0MVYTCTh9sFJclAXdrsG8RXAY85C6BcMdR8ws5YdJ8bMHeIs3z99F+y3uRgojp8D
         xVsT6q6dtTd9iD8/CcYD7LGyxOtgWwzuD4DyeagfKR4jkVD+ZyvWqFjImjc5ZceeGSw8
         HZm8htykIgLum+o7SS9uNvOtCFUA4N4WGytAji1xFYCtgpko8CIUaRYY2QFKnQjHt6K7
         R7NLYw7L2EOfQVnP43GEkXppZ4kqB3FmmIHLF0MnVkJWzJdkGSOHI1uCU1+SWSqqhnQy
         zu1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=eCiD5gjvW3NVWsHXwQGeP5ZKsJarbf2O5NIyqu7kJU0=;
        b=x61jTP+bGZfYxDg0l2mv3CekY4vdmmAN7sOr6IpqB25LN2c6O5MIYdhLC+66Edupo4
         wtD7B8Q374JcKFV5xS3743PtP/i+/O9VF8JwZlQTtw5ljoiiWCsNCZavIEGPK48uKldG
         GoOwaqsP6GYinhXaPJvWEuQX8LqabE+RONJ/n1yH55LewvtMEK5jD9Xvmfx/8AXK/v52
         oECBkf5MqQfJyPSrqnrsdltfGDFQDydW/ZNkVqt1d7aatojK+LDnqctlqwlhBVZ9bzeT
         0gbOD9BRkv13aBJRG0MHe/btVWjVB7Wvt8/29wBJouSKtAPu5rQxy4oF+WCVTR9wbQbT
         bi2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r25si4703408pfd.91.2019.03.21.13.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:02:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 13:02:56 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,254,1549958400"; 
   d="scan'208";a="309246228"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 21 Mar 2019 13:02:55 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH 0/5] Page demotion for memory reclaim
Date: Thu, 21 Mar 2019 14:01:52 -0600
Message-Id: <20190321200157.29678-1-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel has recently added support for using persistent memory as
normal RAM:

  https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4

The persistent memory is hot added to nodes separate from other memory
types, which makes it convenient to make node based memory policies.

When persistent memory provides a larger and cheaper address space, but
with slower access characteristics than system RAM, we'd like the kernel
to make use of these memory-only nodes as a migration tier for pages
that would normally be discared during memory reclaim. This is faster
than doing IO for swap or page cache, and makes better utilization of
available physical address space.

The feature is not enabled by default. The user must opt-in to kernel
managed page migration by defining the demotion path. In the future,
we may want to have the kernel automatically create this based on
heterogeneous memory attributes and CPU locality.

Keith Busch (5):
  node: Define and export memory migration path
  mm: Split handling old page for migration
  mm: Attempt to migrate page in lieu of discard
  mm: Consider anonymous pages without swap
  mm/migrate: Add page movement trace event

 Documentation/ABI/stable/sysfs-devices-node |  11 +-
 drivers/base/node.c                         |  73 +++++++++++++
 include/linux/migrate.h                     |   6 ++
 include/linux/node.h                        |   6 ++
 include/linux/swap.h                        |  20 ++++
 include/trace/events/migrate.h              |  29 ++++-
 mm/debug.c                                  |   1 +
 mm/migrate.c                                | 161 ++++++++++++++++++----------
 mm/vmscan.c                                 |  25 ++++-
 9 files changed, 271 insertions(+), 61 deletions(-)

-- 
2.14.4

