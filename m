Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA6F6B006C
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 17:31:27 -0500 (EST)
Received: by padbj1 with SMTP id bj1so21376900pad.12
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 14:31:27 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bn0108.outbound.protection.outlook.com. [157.56.110.108])
        by mx.google.com with ESMTPS id qm16si4851223pab.124.2015.03.06.14.31.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Mar 2015 14:31:26 -0800 (PST)
From: Yannick Guerrini <yguerrini@tomshardware.fr>
Subject: [PATCHv2] percpu: Fix trivial typos in comments
Date: Fri, 6 Mar 2015 23:30:42 +0100
Message-ID: <1425681042-8416-1-git-send-email-yguerrini@tomshardware.fr>
In-Reply-To: <20150306220228.GC15052@htj.duckdns.org>
References: <20150306220228.GC15052@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: cl@linux-foundation.org, trivial@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yannick Guerrini <yguerrini@tomshardware.fr>

Change 'tranlated' to 'translated'
Change 'mutliples' to 'multiples'

Signed-off-by: Yannick Guerrini <yguerrini@tomshardware.fr>
---
v2: don't replace 'iff' by 'if' !
    as suggested by Tejun Heo <tj@kernel.org>


 mm/percpu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 73c97a5..dfd0248 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1310,7 +1310,7 @@ bool is_kernel_percpu_address(unsigned long addr)
  * and, from the second one, the backing allocator (currently either vm or
  * km) provides translation.
  *
- * The addr can be tranlated simply without checking if it falls into the
+ * The addr can be translated simply without checking if it falls into the
  * first chunk. But the current code reflects better how percpu allocator
  * actually works, and the verification can discover both bugs in percpu
  * allocator itself and per_cpu_ptr_to_phys() callers. So we keep current
@@ -1762,7 +1762,7 @@ early_param("percpu_alloc", percpu_alloc_setup);
  * and other parameters considering needed percpu size, allocation
  * atom size and distances between CPUs.
  *
- * Groups are always mutliples of atom size and CPUs which are of
+ * Groups are always multiples of atom size and CPUs which are of
  * LOCAL_DISTANCE both ways are grouped together and share space for
  * units in the same group.  The returned configuration is guaranteed
  * to have CPUs on different nodes on different groups and >=75% usage
-- 
1.9.5.msysgit.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
