Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07C956B4DA0
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 10:24:15 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s19so26768255qke.20
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:24:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w39si5372279qtc.168.2018.11.28.07.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 07:24:14 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] sysctl: clean up nr_pdflush_threads leftover
Date: Wed, 28 Nov 2018 10:24:07 -0500
Message-Id: <20181128152407.19062-1-aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, davem@davemloft.net, virgile@acceis.fr, linux-mm@kvack.org

nr_pdflush_threads has been long deprecated and
removed, but a remnant of its glorious past is
still around in CTL_VM names enum. This patch
is a minor clean-up to that case.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 include/uapi/linux/sysctl.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index d71013fffaf6..dad5a8f93343 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -174,7 +174,7 @@ enum
 	VM_DIRTY_RATIO=12,	/* dirty_ratio */
 	VM_DIRTY_WB_CS=13,	/* dirty_writeback_centisecs */
 	VM_DIRTY_EXPIRE_CS=14,	/* dirty_expire_centisecs */
-	VM_NR_PDFLUSH_THREADS=15, /* nr_pdflush_threads */
+	VM_UNUSED15=15,		/* was: int nr_pdflush_threads */
 	VM_OVERCOMMIT_RATIO=16, /* percent of RAM to allow overcommit in */
 	VM_PAGEBUF=17,		/* struct: Control pagebuf parameters */
 	VM_HUGETLB_PAGES=18,	/* int: Number of available Huge Pages */
-- 
2.17.2
