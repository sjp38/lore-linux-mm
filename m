Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED59B6B03B4
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:59:21 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id w34so49630152qtw.17
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:59:21 -0700 (PDT)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com. [209.85.216.170])
        by mx.google.com with ESMTPS id y43si12680492qty.290.2017.04.03.11.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:59:21 -0700 (PDT)
Received: by mail-qt0-f170.google.com with SMTP id x35so120472049qtc.2
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:59:21 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 21/22] staging: android: ion: Set query return value
Date: Mon,  3 Apr 2017 11:58:03 -0700
Message-Id: <1491245884-15852-22-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

This never got set in the ioctl. Properly set a return value of 0 on
success.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 9eeb06f..d6fd350 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -498,6 +498,7 @@ int ion_query_heaps(struct ion_heap_query *query)
 	}
 
 	query->cnt = cnt;
+	ret = 0;
 out:
 	up_read(&dev->lock);
 	return ret;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
