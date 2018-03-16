Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 254F86B0006
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:14:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j17so7293750qth.20
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:14:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v129si7615778qkd.264.2018.03.16.12.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:14:19 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 02/14] mm/hmm: fix header file if/else/endif maze
Date: Fri, 16 Mar 2018 15:14:07 -0400
Message-Id: <20180316191414.3223-3-jglisse@redhat.com>
In-Reply-To: <20180316191414.3223-1-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, stable@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The #if/#else/#endif for IS_ENABLED(CONFIG_HMM) were wrong.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Cc: stable@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
---
 include/linux/hmm.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 325017ad9311..ef6044d08cc5 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -498,6 +498,9 @@ struct hmm_device {
 struct hmm_device *hmm_device_new(void *drvdata);
 void hmm_device_put(struct hmm_device *hmm_device);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
+#else /* IS_ENABLED(CONFIG_HMM) */
+static inline void hmm_mm_destroy(struct mm_struct *mm) {}
+static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM) */
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
@@ -513,8 +516,4 @@ static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
-
-#else /* IS_ENABLED(CONFIG_HMM) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
-static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* LINUX_HMM_H */
-- 
2.14.3
