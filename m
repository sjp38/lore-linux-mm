Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EE4DF6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:07:14 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id p10so3073347pdj.29
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:07:14 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id nf8si4843346pbc.150.2014.02.07.04.07.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:07:10 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so3113615pab.33
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:07:09 -0800 (PST)
Date: Fri, 7 Feb 2014 17:37:05 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 4/9] mm: Mark function as static in process_vm_access.c
Message-ID: <cd2e33f9fd5b160ef5108273d7dbabd8259c4f07.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Rashika Kheria <rashika.kheria@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Al Viro <viro@ZenIV.linux.org.uk>, linux-mm@kvack.org, josh@joshtriplett.org

Mark function as static in process_vm_access.c because it is not used
outside this file.

This eliminates the following warning in mm/process_vm_access.c:
mm/process_vm_access.c:416:1: warning: no previous prototype for a??compat_process_vm_rwa?? [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/process_vm_access.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index fd26d04..f3aabbd 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -412,7 +412,7 @@ SYSCALL_DEFINE6(process_vm_writev, pid_t, pid,
 
 #ifdef CONFIG_COMPAT
 
-asmlinkage ssize_t
+static asmlinkage ssize_t
 compat_process_vm_rw(compat_pid_t pid,
 		     const struct compat_iovec __user *lvec,
 		     unsigned long liovcnt,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
