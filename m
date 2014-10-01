Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id F0D5A6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 11:45:00 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id hi2so1068590wib.3
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:45:00 -0700 (PDT)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id b11si1642472wjb.152.2014.10.01.08.45.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 08:45:00 -0700 (PDT)
Received: by mail-wg0-f41.google.com with SMTP id b13so854726wgh.0
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:45:00 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: memcontrol Use #include <linux/uaccess.h>
Date: Wed,  1 Oct 2014 16:44:56 +0100
Message-Id: <1412178296-2972-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org

Remove asm headers for linux headers

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 085dc6d..51dbe80 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -56,14 +56,14 @@
 #include <linux/oom.h>
 #include <linux/lockdep.h>
 #include <linux/file.h>
+#include <linux/uaccess.h>
+
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/tcp_memcontrol.h>
 #include "slab.h"
 
-#include <asm/uaccess.h>
-
 #include <trace/events/vmscan.h>
 
 struct cgroup_subsys memory_cgrp_subsys __read_mostly;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
