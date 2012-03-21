Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 1BE8E6B00E7
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:56:37 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:56:36 -0700 (PDT)
Subject: [PATCH 05/16] mm/drivers: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:56:33 +0400
Message-ID: <20120321065633.13852.11903.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Mauro Carvalho Chehab <mchehab@infradead.org>, linux-mm@kvack.org, Arve =?utf-8?b?SGrDuG5uZXbDpWc=?= <arve@android.com>, John Stultz <john.stultz@linaro.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-media@vger.kernel.org
Cc: devel@driverdev.osuosl.org
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Mauro Carvalho Chehab <mchehab@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: John Stultz <john.stultz@linaro.org>
Cc: "Arve HjA,nnevAJPYg" <arve@android.com>
---
 drivers/media/video/omap3isp/ispqueue.h |    2 +-
 drivers/staging/android/ashmem.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/media/video/omap3isp/ispqueue.h b/drivers/media/video/omap3isp/ispqueue.h
index 92c5a12..908dfd7 100644
--- a/drivers/media/video/omap3isp/ispqueue.h
+++ b/drivers/media/video/omap3isp/ispqueue.h
@@ -90,7 +90,7 @@ struct isp_video_buffer {
 	void *vaddr;
 
 	/* For userspace buffers. */
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 	unsigned long offset;
 	unsigned int npages;
 	struct page **pages;
diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 9f1f27e..4511420 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -269,7 +269,7 @@ out:
 	return ret;
 }
 
-static inline unsigned long calc_vm_may_flags(unsigned long prot)
+static inline vm_flags_t calc_vm_may_flags(unsigned long prot)
 {
 	return _calc_vm_trans(prot, PROT_READ,  VM_MAYREAD) |
 	       _calc_vm_trans(prot, PROT_WRITE, VM_MAYWRITE) |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
