Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6193F6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 21:09:35 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id l109so4580792yhq.33
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:09:35 -0800 (PST)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id n44si15809926yhn.165.2013.12.10.18.09.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 18:09:34 -0800 (PST)
Received: by mail-pd0-f181.google.com with SMTP id p10so8546524pdj.12
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:09:33 -0800 (PST)
Message-ID: <52A7C9D9.4080308@gmail.com>
Date: Wed, 11 Dec 2013 10:11:37 +0800
From: Chen Gang <gang.chen.5i5j@gmail.com>
MIME-Version: 1.0
Subject: [PATCH v2] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com> <20131209153626.GA3752@cerebellum.variantweb.net> <52A67973.20904@gmail.com>
In-Reply-To: <52A67973.20904@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Hogan <james.hogan@imgtec.com>

Recommend to add default case to avoid compiler's warning, although at
present, the original implementation is still correct.

The related warning (with allmodconfig for metag):

    CC      mm/zswap.o
  mm/zswap.c: In function 'zswap_writeback_entry':
  mm/zswap.c:537: warning: 'ret' may be used uninitialized in this function


Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/zswap.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 5a63f78..f58a001 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -585,6 +585,10 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 
 		/* page is up to date */
 		SetPageUptodate(page);
+		break;
+
+	default:
+		BUG();
 	}
 
 	/* move it to the tail of the inactive list after end_writeback */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
