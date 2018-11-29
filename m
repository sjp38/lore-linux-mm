Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 330106B532E
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:08:36 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k90so2012038qte.0
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 07:08:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x56si1479259qtc.123.2018.11.29.07.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 07:08:35 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v2] sysctl: clean up nr_pdflush_threads leftover
Date: Thu, 29 Nov 2018 10:08:17 -0500
Message-Id: <20181129150817.24443-1-aquini@redhat.com>
In-Reply-To: <20181128152407.19062-1-aquini@redhat.com>
References: <20181128152407.19062-1-aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, davem@davemloft.net, virgile@acceis.fr, linux-mm@kvack.org, william.kucharski@oracle.com

nr_pdflush_threads has been long deprecated and
removed, but a remnant of its glorious past is
still around in CTL_VM names enum. This patch
is a minor clean-up to that case.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
v2:
 - adjust typo "was;" for VM_UNUSED2 comment       [wkucharski]
 - add colon after "int" for VM_UNUSED15 comment   [wkucharski]

 include/uapi/linux/sysctl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index d71013fffaf6..9df59925ed55 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -161,7 +161,7 @@ enum
 enum
 {
 	VM_UNUSED1=1,		/* was: struct: Set vm swapping control */
-	VM_UNUSED2=2,		/* was; int: Linear or sqrt() swapout for hogs */
+	VM_UNUSED2=2,		/* was: int: Linear or sqrt() swapout for hogs */
 	VM_UNUSED3=3,		/* was: struct: Set free page thresholds */
 	VM_UNUSED4=4,		/* Spare */
 	VM_OVERCOMMIT_MEMORY=5,	/* Turn off the virtual memory safety limit */
@@ -174,7 +174,7 @@ enum
 	VM_DIRTY_RATIO=12,	/* dirty_ratio */
 	VM_DIRTY_WB_CS=13,	/* dirty_writeback_centisecs */
 	VM_DIRTY_EXPIRE_CS=14,	/* dirty_expire_centisecs */
-	VM_NR_PDFLUSH_THREADS=15, /* nr_pdflush_threads */
+	VM_UNUSED15=15,		/* was: int: nr_pdflush_threads */
 	VM_OVERCOMMIT_RATIO=16, /* percent of RAM to allow overcommit in */
 	VM_PAGEBUF=17,		/* struct: Control pagebuf parameters */
 	VM_HUGETLB_PAGES=18,	/* int: Number of available Huge Pages */
-- 
2.17.2
