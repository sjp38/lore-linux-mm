Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B4F26B0047
	for <linux-mm@kvack.org>; Sat,  2 May 2009 18:15:52 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 5/6] ksm: build system make it compile for all archs
Date: Sun,  3 May 2009 01:16:11 +0300
Message-Id: <1241302572-4366-6-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241302572-4366-5-git-send-email-ieidus@redhat.com>
References: <1241302572-4366-1-git-send-email-ieidus@redhat.com>
 <1241302572-4366-2-git-send-email-ieidus@redhat.com>
 <1241302572-4366-3-git-send-email-ieidus@redhat.com>
 <1241302572-4366-4-git-send-email-ieidus@redhat.com>
 <1241302572-4366-5-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

The known issues with cross platform support were fixed,
so we return it back to compile on all archs.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f59b1e4..fb8ac63 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -228,7 +228,6 @@ config MMU_NOTIFIER
 
 config KSM
 	tristate "Enable KSM for page sharing"
-	depends on X86
 	help
 	  Enable the KSM kernel module to allow page sharing of equal pages
 	  among different tasks.
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
