Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 922616B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 06:27:22 -0500 (EST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: [PATCH 0/4] Miscellaneous dma-buf patches
Date: Thu, 26 Jan 2012 12:27:21 +0100
Message-Id: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

Hi Sumit,

Here are 4 dma-buf patches that fix small issues.

Laurent Pinchart (4):
  dma-buf: Constify ops argument to dma_buf_export()
  dma-buf: Remove unneeded sanity checks
  dma-buf: Return error instead of using a goto statement when possible
  dma-buf: Move code out of mutex-protected section in dma_buf_attach()

 drivers/base/dma-buf.c  |   26 +++++++++++---------------
 include/linux/dma-buf.h |    8 ++++----
 2 files changed, 15 insertions(+), 19 deletions(-)

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
