Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB03F6B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 10:31:46 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v198-v6so9602473qka.16
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 07:31:46 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p9-v6sor7931528qtq.153.2018.10.01.07.31.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 07:31:46 -0700 (PDT)
Date: Mon,  1 Oct 2018 16:31:36 +0200
Message-Id: <20181001143138.95119-1-jannh@google.com>
Mime-Version: 1.0
Subject: [PATCH v2 1/3] mm/vmstat: fix outdated vmstat_text
From: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jannh@google.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
removed the VMACACHE_FULL_FLUSHES statistics, but didn't remove the
corresponding entry in vmstat_text. This causes an out-of-bounds access in
vmstat_show().

Luckily this only affects kernels with CONFIG_DEBUG_VM_VMACACHE=y, which is
probably very rare.

Fixes: 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
Cc: stable@vger.kernel.org
Signed-off-by: Jann Horn <jannh@google.com>
---
 mm/vmstat.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8ba0870ecddd..4cea7b8f519d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1283,7 +1283,6 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_DEBUG_VM_VMACACHE
 	"vmacache_find_calls",
 	"vmacache_find_hits",
-	"vmacache_full_flushes",
 #endif
 #ifdef CONFIG_SWAP
 	"swap_ra",
-- 
2.19.0.605.g01d371f741-goog
