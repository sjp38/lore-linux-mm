Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id F3CB96B006C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 10:32:40 -0500 (EST)
From: James Hogan <james.hogan@imgtec.com>
Subject: [PATCH v3 35/44] mm: define VM_GROWSUP for CONFIG_METAG
Date: Thu, 10 Jan 2013 15:31:03 +0000
Message-ID: <1357831872-29451-36-git-send-email-james.hogan@imgtec.com>
In-Reply-To: <1357831872-29451-1-git-send-email-james.hogan@imgtec.com>
References: <1357831872-29451-1-git-send-email-james.hogan@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: James Hogan <james.hogan@imgtec.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel
 Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

Commit cc2383ec06be093789469852e1fe96e1148e9a2c ("mm: introduce
arch-specific vma flag VM_ARCH_1") merged in v3.7-rc1.

The above commit combined several arch-specific vma flags into one, and
in the process it changed the VM_GROWSUP definition to depend on
specific architectures rather than CONFIG_STACK_GROWSUP. Therefore add
an ifdef for CONFIG_METAG to also set VM_GROWSUP.

Signed-off-by: James Hogan <james.hogan@imgtec.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
---
 include/linux/mm.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6320407..f71abc6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -114,6 +114,8 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_SAO		VM_ARCH_1	/* Strong Access Ordering (powerpc) */
 #elif defined(CONFIG_PARISC)
 # define VM_GROWSUP	VM_ARCH_1
+#elif defined(CONFIG_METAG)
+# define VM_GROWSUP	VM_ARCH_1
 #elif defined(CONFIG_IA64)
 # define VM_GROWSUP	VM_ARCH_1
 #elif !defined(CONFIG_MMU)
-- 
1.7.7.6


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
