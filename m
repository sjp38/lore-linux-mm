Received: by ro-out-1112.google.com with SMTP id p7so2106482roc
        for <linux-mm@kvack.org>; Mon, 05 Nov 2007 19:13:13 -0800 (PST)
Date: Tue, 6 Nov 2007 11:12:07 +0800
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [git Patch] mm/util.c: Remove needless code
Message-ID: <20071106031207.GA2478@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Dong Pu <cocobear.cn@gmail.com>
List-ID: <linux-mm.kvack.org>

If the code can be executed there, 'new_size' is always larger
than 'ks'. Thus min() is needless.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Signed-off-by: Dong Pu <cocobear.cn@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>

---
 mm/util.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/util.c b/mm/util.c
index 5f64026..295c7aa 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -96,7 +96,7 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
 
 	ret = kmalloc_track_caller(new_size, flags);
 	if (ret) {
-		memcpy(ret, p, min(new_size, ks));
+		memcpy(ret, p, ks);
 		kfree(p);
 	}
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
