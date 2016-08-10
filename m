Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8AE6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 04:04:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so49619366wmu.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 01:04:32 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id sr6si38642339wjb.281.2016.08.10.01.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 01:04:31 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id i5so7940253wmg.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 01:04:31 -0700 (PDT)
Date: Wed, 10 Aug 2016 17:03:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 3/5] mm/page_owner: move page_owner specific function to
 page_owner.c
Message-ID: <20160810080355.GA573@swordfish>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470809784-11516-4-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello Joonsoo,

just in case,
---

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 3b241f5..bff2d8a 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -8,6 +8,7 @@
 #include <linux/jump_label.h>
 #include <linux/migrate.h>
 #include <linux/stackdepot.h>
+#include <linux/seq_file.h>
 
 #include "internal.h"
 
---

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>



---

ps. I'm traveling now, with somewhat loose internet connection, so may
be a bit slow to reply.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
