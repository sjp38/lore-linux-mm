Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86A696B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 06:48:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13so25054038pgn.4
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 03:48:57 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e67si678181pfg.409.2017.06.09.03.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 03:48:56 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v11 2/6] virtio-balloon: coding format cleanup
Date: Fri,  9 Jun 2017 18:41:37 +0800
Message-Id: <1497004901-30593-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

Clean up the comment format.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 drivers/virtio/virtio_balloon.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 4a9f307..ecb64e9 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -132,8 +132,10 @@ static void set_page_pfns(struct virtio_balloon *vb,
 {
 	unsigned int i;
 
-	/* Set balloon pfns pointing at this page.
-	 * Note that the first pfn points at start of the page. */
+	/*
+	 * Set balloon pfns pointing at this page.
+	 * Note that the first pfn points at start of the page.
+	 */
 	for (i = 0; i < VIRTIO_BALLOON_PAGES_PER_PAGE; i++)
 		pfns[i] = cpu_to_virtio32(vb->vdev,
 					  page_to_balloon_pfn(page) + i);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
