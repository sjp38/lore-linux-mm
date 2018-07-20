Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3176B026E
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:34:39 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c27-v6so9275131qkj.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:34:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e123-v6si1702869qkf.88.2018.07.20.05.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 05:34:38 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 1/2] mm: clarify semantics of reserved pages
Date: Fri, 20 Jul 2018 14:34:21 +0200
Message-Id: <20180720123422.10127-2-david@redhat.com>
In-Reply-To: <20180720123422.10127-1-david@redhat.com>
References: <20180720123422.10127-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Petr Tesarik <ptesarik@suse.cz>

The reserved bit once was used to hinder pages from getting swapped. While
this still works, the semantics are a little bit stronger nowadays: The
page should never be touched by anybody in the system except by the owner.
The original comment already gave a hint about that.

So especially, these pages should also not be dumped by dumping tools.
Let's make that more clear by updating the comment.

This will be useful especially in the future in virtual environments where
pages marked with the reserved bit might no longer be accessible.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Miles Chen <miles.chen@mediatek.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: "Marc-AndrA(C) Lureau" <marcandre.lureau@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/page-flags.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 901943e4754b..ba81e11a868c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -17,8 +17,8 @@
 /*
  * Various page->flags bits:
  *
- * PG_reserved is set for special pages, which can never be swapped out. Some
- * of them might not even exist...
+ * PG_reserved is set for special pages, which should never be touched (read/
+ * write) by anybody except their owner. Some of them might not even exist.
  *
  * The PG_private bitflag is set on pagecache pages if they contain filesystem
  * specific data (which is normally at page->private). It can be used by
-- 
2.17.1
