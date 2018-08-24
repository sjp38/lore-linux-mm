Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2D3F6B312D
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 15:25:53 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u45-v6so8811978qte.12
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 12:25:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 6-v6si8295757qks.284.2018.08.24.12.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 12:25:52 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 1/7] mm/hmm: fix utf8 ...
Date: Fri, 24 Aug 2018 15:25:43 -0400
Message-Id: <20180824192549.30844-2-jglisse@redhat.com>
In-Reply-To: <20180824192549.30844-1-jglisse@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Somehow utf=8 must have been broken.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h | 2 +-
 mm/hmm.c            | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4c92e3ba3e16..1ff4bae7ada7 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -11,7 +11,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
- * Authors: JA?A(C)rA?A'me Glisse <jglisse@redhat.com>
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
  */
 /*
  * Heterogeneous Memory Management (HMM)
diff --git a/mm/hmm.c b/mm/hmm.c
index c968e49f7a0c..9a068a1da487 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -11,7 +11,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
- * Authors: JA?A(C)rA?A'me Glisse <jglisse@redhat.com>
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
  */
 /*
  * Refer to include/linux/hmm.h for information about heterogeneous memory
-- 
2.17.1
