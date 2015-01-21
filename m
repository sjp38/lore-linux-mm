Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 165CC6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 23:17:27 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id v10so29040618pde.10
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 20:17:26 -0800 (PST)
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com. [209.85.220.44])
        by mx.google.com with ESMTPS id tv6si7235356pab.83.2015.01.20.20.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 20:17:25 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so50197704pad.3
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 20:17:23 -0800 (PST)
From: Sumit Semwal <sumit.semwal@linaro.org>
Subject: [RFCv2 0/2] dma-parms, constraints and helpers for dma-buf
Date: Wed, 21 Jan 2015 09:46:45 +0530
Message-Id: <1421813807-9178-1-git-send-email-sumit.semwal@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: linaro-kernel@lists.linaro.org, robdclark@gmail.com, daniel@ffwll.ch, m.szyprowski@samsung.com, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>

Hello Everyone,

Based on review comments received, I've split my earlier patchset on
'dma-buf constraints-enabled allocation' [1] into 2 sets:
- first one is this one, to use dma_parms and related parameters from
   struct device to share constraints, and then to use these constraints in
   dma-buf to help find the least common constraint set that could then be
   used by exporters to decide on allocation.

   This is a partial re-write of what Rob Clark proposed some while ago [2];
   I've tried to take care of review comments on his patchset, but any errors
   and omissions are, ofcourse, mine.

- Second part, one which I'm working on, and will post soon, aims at adding
   allocator-helpers in dma-buf framework which could use this constraint
   information to help choose the right allocator from a list.

While I work on the second part, I thought of sending the RFC for this one,
to get feedback on whether this mechanism seems ok to everyone.

[1] https://lkml.org/lkml/2014/10/10/340
[2] https://lkml.org/lkml/2012/7/19/285

Rob Clark (1):
  device: add dma_params->max_segment_count

Sumit Semwal (1):
  dma-buf: add helpers for sharing attacher constraints with dma-parms

 drivers/dma-buf/dma-buf.c   | 134 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/device.h      |   1 +
 include/linux/dma-buf.h     |  22 ++++++++
 include/linux/dma-mapping.h |  19 +++++++
 4 files changed, 175 insertions(+), 1 deletion(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
