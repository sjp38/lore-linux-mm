Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4181B6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:52:39 -0500 (EST)
Received: by wmec201 with SMTP id c201so62695502wme.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:52:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w138si9400475wmw.32.2015.11.27.01.52.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 01:52:37 -0800 (PST)
Subject: Re: [PATCH v2 1/9] mm, debug: fix wrongly filtered flags in
 dump_vma()
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-2-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565827E3.1000708@suse.cz>
Date: Fri, 27 Nov 2015 10:52:35 +0100
MIME-Version: 1.0
In-Reply-To: <1448368581-6923-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 26 Nov 2015 15:39:27 +0100
Subject: [PATCH] mm, debug: fix wrongly filtered flags in dump_vma()-fix

Don't print opening parenthesis twice.
---
  mm/debug.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index d9718fc8377a..68118399c2b6 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -240,7 +240,7 @@ void dump_mm(const struct mm_struct *mm)
  		""		/* This is here to not have a comma! */
  		);

-	pr_emerg("def_flags: %#lx(", mm->def_flags);
+	pr_emerg("def_flags: %#lx", mm->def_flags);
  	dump_flag_names(mm->def_flags, vmaflags_names,
  					ARRAY_SIZE(vmaflags_names));
  }
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
