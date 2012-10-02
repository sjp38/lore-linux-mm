Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id EC76A6B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 19:59:51 -0400 (EDT)
Date: Tue, 2 Oct 2012 16:49:34 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: use %pK for /proc/vmallocinfo
Message-ID: <20121002234934.GA9194@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joe Perches <joe@perches.com>, Kautuk Consul <consul.kautuk@gmail.com>, linux-mm@kvack.org, Brad Spengler <spender@grsecurity.net>

In the paranoid case of sysctl kernel.kptr_restrict=2, mask the kernel
virtual addresses in /proc/vmallocinfo too.

Reported-by: Brad Spengler <spender@grsecurity.net>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/vmalloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2bb90b1..9c871db 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2572,7 +2572,7 @@ static int s_show(struct seq_file *m, void *p)
 {
 	struct vm_struct *v = p;
 
-	seq_printf(m, "0x%p-0x%p %7ld",
+	seq_printf(m, "0x%pK-0x%pK %7ld",
 		v->addr, v->addr + v->size, v->size);
 
 	if (v->caller)
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
