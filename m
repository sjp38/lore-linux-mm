Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7367EC282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 080B62184D
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:02:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HLK1mCiE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 080B62184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57A108E0002; Wed, 30 Jan 2019 22:02:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 500CD8E0001; Wed, 30 Jan 2019 22:02:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A1738E0002; Wed, 30 Jan 2019 22:02:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0E978E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:02:21 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so1151252pgc.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:02:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=21JlOZW7w0wGlQ1y8Y5t+ZogP9kpInVIgyeEdo29DZ4=;
        b=efg0rqKpz59eO8+gdA1YAGpyhzwOUePPcX004C3r83VpB7A9EvDSMgj47dqjr9u+ar
         evB+paZNwzpZjW7hLcj+JCwIgcBF/K5mEZ95FZCLGlE+g8FUdGvGUGzJQo7GsPhyV5yN
         xA7mz1+BhbPVW1paXrBq58kHy4Z5FeNcsaO4OnZ1RNZFuIlme9mR1NtW9NjbSBpFkLLA
         WLame+VGSmBFXyrQQXkbR4xqWHOseJtylaQYFUAfVZpLUQ4Jpxw0LNNlQehM7miSas19
         DYUSLo1oJ2U6agWfuu42VHVewJe05g/8B09ue/Pvaazy/tAiJEWkAdLhaiwi8ZZpBHI3
         7+6g==
X-Gm-Message-State: AJcUukftrJS0i698EP3dphPEmWT9+H6F02CPyQHn2rPExslRz1Le+aWO
	IkdonfiVOjqW+dbV2yPvENdQsCTWoHfMGDhaXs5jQDn04WOk2D+07kATuoWGe8YswuDoCSMiBBu
	SHEG9b8kFKqI7KXWboIWRuI+/A2NLUyagzgpwVpba7fCgU+Ph2J0RGCTqyuwC2AisnCgQ0dkeYm
	yTXLF+HFtwN/Z2RKTij9DXS7KRHxf9sDxVL94JrEhN1kn0/4jFInUmhi+Yu6wZBYbvvuDWS0E//
	JnZ3+t0a74Di4i3nOWCqg+ZPvw6DpGFga7YgvhYrxDCaibkGyJ4nNoBZ/V+cFKlgqtiag57IpLT
	1JwbIa3jEdrcC06n4ldVJIn6ChDoz79RLixi/5sqCjnkpNhzirSeqhKOOggBt/qfrobOrTKybR+
	s
X-Received: by 2002:a63:e247:: with SMTP id y7mr28549437pgj.84.1548903741390;
        Wed, 30 Jan 2019 19:02:21 -0800 (PST)
X-Received: by 2002:a63:e247:: with SMTP id y7mr28549376pgj.84.1548903740337;
        Wed, 30 Jan 2019 19:02:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548903740; cv=none;
        d=google.com; s=arc-20160816;
        b=oNFYPx9CZN13XcMlLmlb89Ion3C+ZpmSdVefxUPAS7qnxJGRMlh/I/c2xqkKnusGHJ
         YQUCC8N/CzOIkvBF5AHjnuHCD/tR6FJTcld+vbUD4W9NdE6ZHq6KFjAaMC8/LhpKwqMo
         a6NSTO6Puz41/3EPef+aaHlySHXZyQWb6c+HVYnJ8IywOIls/cdLPgMdG06OP19Umtpc
         v3iC70a9gZOHaiS1XTxqJhMj4KdOCOhp9sj61LG28y4UrRpwmXkvNSbGNpuAGsDrxqqF
         nTbr7WbS/+pwDoVxioPIQbRK5a25zL3a6crIsbPdcdJPu7M++N9Lxp9YeDR6/pZjOXNE
         OA/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=21JlOZW7w0wGlQ1y8Y5t+ZogP9kpInVIgyeEdo29DZ4=;
        b=BmMR8/qNXuY8DQf7xemaS6iuAFX0pgxpAX0pa1FhQigqNm8KlUKA3W615go4ScQ+yH
         oVLsiz7ZT2IXn5ztElmgDJiCtL2bS5xyUXqL4oIax/KWgjhKLk8MIV4LRxr5rbQVqL8G
         x+XukKkKS3XcZxe9mCldk8TYrLS/T3DTyDPEyUQas36jAXWu+lQI9RZaBFKj6Gk+kjDc
         QF9+Yb0y7BaggSesY05V+BPF9ZRJTpxwmZkLxUoKy9UDjk8h1jt+tOpGaSIxiFY1C6vG
         BT9B9GV48ypOL67RBu4QldLSo3UyMvkBIQQ4dSlal/mGeQUN9lEnpTWKCvEsNCwamqmc
         B4DA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HLK1mCiE;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r29sor5400190pfk.38.2019.01.30.19.02.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:02:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HLK1mCiE;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=21JlOZW7w0wGlQ1y8Y5t+ZogP9kpInVIgyeEdo29DZ4=;
        b=HLK1mCiE4dJ18NQVGULIPA8PiIQBws4yp45iUs2ySQEmrEgnAA/9srUZ4RyfZUPVBB
         1cO4YvLYxzKXCmtPQoWx9SlL7yM0nsYjzuAK+jUZJ41cXH/n/cajKPwrrtNroCLCvT+L
         gTlfXkP3sBrFbRX37yKy7ueR/aRnJQrJqkNWKTBFaSSn2y8edx5+l4K0+qZdTPiYk6rD
         DvAjFufGk5qn1qxwiwg5doR0KJWOlGK5OKTVMAYnWPER++voTOoBPAEyvk2B8hiJrJvb
         LctK6KjtdAlhs8txfTflbU+KWxPwpg/vlLc3M5LbIRWqlzewm8SPIu8ueDJef3Mq4tGC
         zMXA==
X-Google-Smtp-Source: ALg8bN5clhF3QoFQslXO5sN+wDZpJqdy7zBe18sX7y+qjCHp8D9i5kDDQHTQn9V7rPsgCAs2+L0urQ==
X-Received: by 2002:a62:4181:: with SMTP id g1mr33008551pfd.45.1548903739568;
        Wed, 30 Jan 2019 19:02:19 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id h128sm4118706pgc.15.2019.01.30.19.02.17
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:02:18 -0800 (PST)
Date: Thu, 31 Jan 2019 08:36:31 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com,
	sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de,
	airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org,
	pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org,
	boris.ostrovsky@oracle.com, jgross@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org
Subject: [PATCHv2 0/9] Use vm_insert_range and vm_insert_range_buggy
Message-ID: <20190131030631.GA1868@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Previouly drivers have their own way of mapping range of
kernel pages/memory into user vma and this was done by
invoking vm_insert_page() within a loop.

As this pattern is common across different drivers, it can
be generalized by creating new functions and use it across
the drivers.

vm_insert_range() is the API which could be used to mapped
kernel memory/pages in drivers which has considered vm_pgoff

vm_insert_range_buggy() is the API which could be used to map
range of kernel memory/pages in drivers which has not considered
vm_pgoff. vm_pgoff is passed default as 0 for those drivers.

We _could_ then at a later "fix" these drivers which are using
vm_insert_range_buggy() to behave according to the normal vm_pgoff
offsetting simply by removing the _buggy suffix on the function
name and if that causes regressions, it gives us an easy way to revert.

v1 -> v2:
	Few Reviewed-by.

        Updated the change log in [8/9]

	In [7/9], vm_pgoff is treated in V4L2 API as a 'cookie'
	to select a buffer, not as a in-buffer offset by design
	and it always want to mmap a whole buffer from its beginning.
	Added additional changes after discussing with Marek and
	vm_insert_range could be used instead of vm_insert_range_buggy.

Souptick Joarder (9):
  mm: Introduce new vm_insert_range and vm_insert_range_buggy API
  arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
  drivers/firewire/core-iso.c: Convert to use vm_insert_range_buggy
  drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
  drm/xen/xen_drm_front_gem.c: Convert to use vm_insert_range
  iommu/dma-iommu.c: Convert to use vm_insert_range
  videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range
  xen/gntdev.c: Convert to use vm_insert_range
  xen/privcmd-buf.c: Convert to use vm_insert_range_buggy

 arch/arm/mm/dma-mapping.c                          | 22 ++----
 drivers/firewire/core-iso.c                        | 15 +---
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        | 17 +----
 drivers/gpu/drm/xen/xen_drm_front_gem.c            | 18 ++---
 drivers/iommu/dma-iommu.c                          | 12 +---
 drivers/media/common/videobuf2/videobuf2-core.c    |  7 ++
 .../media/common/videobuf2/videobuf2-dma-contig.c  |  6 --
 drivers/media/common/videobuf2/videobuf2-dma-sg.c  | 22 ++----
 drivers/xen/gntdev.c                               | 16 ++---
 drivers/xen/privcmd-buf.c                          |  8 +--
 include/linux/mm.h                                 |  4 ++
 mm/memory.c                                        | 81 ++++++++++++++++++++++
 mm/nommu.c                                         | 14 ++++
 13 files changed, 136 insertions(+), 106 deletions(-)

-- 
1.9.1

