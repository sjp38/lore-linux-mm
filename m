Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 195456B0010
	for <linux-mm@kvack.org>; Sat,  5 May 2018 16:07:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d4-v6so16733538wrn.15
        for <linux-mm@kvack.org>; Sat, 05 May 2018 13:07:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b18-v6sor1051327wme.90.2018.05.05.13.07.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 May 2018 13:07:09 -0700 (PDT)
From: Mathieu Malaterre <malat@debian.org>
Subject: [PATCH] =?UTF-8?q?slub:=20add=20=5F=5Fprintf=20verification=20to?= =?UTF-8?q?=20=E2=80=98slab=5Ferr=E2=80=99:?=
Date: Sat,  5 May 2018 22:07:05 +0200
Message-Id: <20180505200706.19986-1-malat@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mathieu Malaterre <malat@debian.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

__printf is useful to verify format and arguments. Remove the following
warning (with W=1):

  mm/slub.c:721:2: warning: function might be possible candidate for a??gnu_printfa?? format attribute [-Wsuggest-attribute=format]

Signed-off-by: Mathieu Malaterre <malat@debian.org>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 44aa7847324a..7d38cfb6a619 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -711,7 +711,7 @@ void object_err(struct kmem_cache *s, struct page *page,
 	print_trailer(s, page, object);
 }
 
-static void slab_err(struct kmem_cache *s, struct page *page,
+static __printf(3, 4) void slab_err(struct kmem_cache *s, struct page *page,
 			const char *fmt, ...)
 {
 	va_list args;
-- 
2.11.0
