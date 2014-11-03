Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 54FA36B00FE
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 12:17:51 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id s18so5386499lam.28
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 09:17:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ui10si33318050lbb.62.2014.11.03.09.17.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 09:17:50 -0800 (PST)
Date: Mon, 3 Nov 2014 18:17:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141103171748.GI10156@dhcp22.suse.cz>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Documentation/cgroups/memory.txt is outdate even more hopelessly than
before. It deserves a complete rewrite but I guess something like the
following should be added in the meantime to prepare potential readers
about the trap.
---
diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 67613ff0270c..46b2b5080317 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -1,5 +1,10 @@
 Memory Resource Controller
 
+NOTE: This document is hopelessly outdated and it asks for a complete
+      rewrite. It still contains a useful information so we are keeping it
+      here but make sure to check the current code if you need a deeper
+      understanding.
+
 NOTE: The Memory Resource Controller has generically been referred to as the
       memory controller in this document. Do not confuse memory controller
       used here with the memory controller that is used in hardware.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
