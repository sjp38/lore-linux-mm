Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 589BE9000BD
	for <linux-mm@kvack.org>; Sat, 17 Sep 2011 10:00:15 -0400 (EDT)
Received: by gya6 with SMTP id 6so4614567gya.14
        for <linux-mm@kvack.org>; Sat, 17 Sep 2011 07:00:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316267014-10372-1-git-send-email-omycle@gmail.com>
References: <1316267014-10372-1-git-send-email-omycle@gmail.com>
Date: Sat, 17 Sep 2011 22:00:13 +0800
Message-ID: <CAFNq8R4N20tk82FxGK8iiV4A0iKEUWh30mjEtmnM+dHJ1bwQ+A@mail.gmail.com>
Subject: [PATCH] mm: Fix the comment the kunmap_high()
From: Li Haifeng <omycle@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fix the comment of kunmap_high()

Signed-off-by: Li Haifeng <omycle@gmail.com>
---
=A0mm/highmem.c | =A0 =A02 +-
=A01 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 5ef672c..7b2e544 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -250,7 +250,7 @@ void *kmap_high_get(struct page *page)
=A0#endif

=A0/**
- * kunmap_high - map a highmem page into memory
+ * kunmap_high - unmap a highmem page from memory
=A0* @page: &struct page to unmap
=A0*
=A0* If ARCH_NEEDS_KMAP_HIGH_GET is not defined then this may be called
--
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
