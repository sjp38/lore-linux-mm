Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F7F46B004D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 18:15:57 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 6/6] ksm: use another miscdevice minor number.
Date: Sun,  3 May 2009 01:16:12 +0300
Message-Id: <1241302572-4366-7-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241302572-4366-6-git-send-email-ieidus@redhat.com>
References: <1241302572-4366-1-git-send-email-ieidus@redhat.com>
 <1241302572-4366-2-git-send-email-ieidus@redhat.com>
 <1241302572-4366-3-git-send-email-ieidus@redhat.com>
 <1241302572-4366-4-git-send-email-ieidus@redhat.com>
 <1241302572-4366-5-git-send-email-ieidus@redhat.com>
 <1241302572-4366-6-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

The old number was registered already by another project.
The new number is #234.

Thanks.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 Documentation/devices.txt  |    1 +
 include/linux/miscdevice.h |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Documentation/devices.txt b/Documentation/devices.txt
index 53d64d3..a0c3259 100644
--- a/Documentation/devices.txt
+++ b/Documentation/devices.txt
@@ -443,6 +443,7 @@ Your cooperation is appreciated.
 		231 = /dev/snapshot	System memory snapshot device
 		232 = /dev/kvm		Kernel-based virtual machine (hardware virtualization extensions)
 		233 = /dev/kmview	View-OS A process with a view
+		234 = /dev/ksm		Dynamic page sharing
 		240-254			Reserved for local use
 		255			Reserved for MISC_DYNAMIC_MINOR
 
diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index 297c0bb..c7b8e9b 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -30,7 +30,7 @@
 #define HPET_MINOR		228
 #define FUSE_MINOR		229
 #define KVM_MINOR		232
-#define KSM_MINOR		233
+#define KSM_MINOR		234
 #define MISC_DYNAMIC_MINOR	255
 
 struct device;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
