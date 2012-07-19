Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id BAC546B0068
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 12:24:47 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2137205qcs.14
        for <linux-mm@kvack.org>; Thu, 19 Jul 2012 09:24:46 -0700 (PDT)
From: Rob Clark <rob.clark@linaro.org>
Subject: [PATCH 0/2] dma-parms and helpers for dma-buf
Date: Thu, 19 Jul 2012 11:23:32 -0500
Message-Id: <1342715014-5316-1-git-send-email-rob.clark@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org
Cc: patches@linaro.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, daniel@ffwll.ch, t.stanislaws@samsung.com, sumit.semwal@ti.com, maarten.lankhorst@canonical.com, Rob Clark <rob@ti.com>

From: Rob Clark <rob@ti.com>

Re-sending first patch, with a wider audience.  Apparently I didn't
spam enough inboxes the first time.

And, at Daniel Vetter's suggestion, adding some helper functions in
dma-buf to get the most restrictive parameters of all the attached
devices.

Rob Clark (2):
  device: add dma_params->max_segment_count
  dma-buf: add helpers for attacher dma-parms

 drivers/base/dma-buf.c      |   63 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/device.h      |    1 +
 include/linux/dma-buf.h     |   19 +++++++++++++
 include/linux/dma-mapping.h |   16 +++++++++++
 4 files changed, 99 insertions(+)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
