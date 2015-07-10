Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id E8CE56B0254
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 11:26:27 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so49697412wiw.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 08:26:27 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id j5si4007260wix.21.2015.07.10.08.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 08:26:26 -0700 (PDT)
Received: by widjy10 with SMTP id jy10so18479969wid.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 08:26:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] MAINTAINERS: change my email address to kernel.org
Date: Fri, 10 Jul 2015 17:26:07 +0200
Message-Id: <1436541967-23513-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

I am moving from mhocko@suse.cz to mhocko@kernel.org for kernel related
stuff.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 141646329d6c..ca7fabeb5505 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2731,7 +2731,7 @@ F:	kernel/cpuset.c
 
 CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)
 M:	Johannes Weiner <hannes@cmpxchg.org>
-M:	Michal Hocko <mhocko@suse.cz>
+M:	Michal Hocko <mhocko@kernel.org>
 L:	cgroups@vger.kernel.org
 L:	linux-mm@kvack.org
 S:	Maintained
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
