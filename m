Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F395F6B028A
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:38 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z1so16243254qtz.12
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s3si5394548qte.4.2018.04.04.12.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:32 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 74/79] mm/page_ronly: add config option for generic read only page framework.
Date: Wed,  4 Apr 2018 15:18:26 -0400
Message-Id: <20180404191831.5378-37-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

It's really just a config option patch.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/Kconfig | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index c782e8fb7235..aeffb6e8dd21 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -149,6 +149,9 @@ config NO_BOOTMEM
 config MEMORY_ISOLATION
 	bool
 
+config PAGE_RONLY
+	bool
+
 #
 # Only be set on architectures that have completely implemented memory hotplug
 # feature. If you are not sure, don't touch it.
-- 
2.14.3
