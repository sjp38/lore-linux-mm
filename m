Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 429656B003A
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:01:01 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so3060792pad.3
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:01:00 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id ty3si9148344pbc.107.2013.12.16.07.00.57
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 07:00:57 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 1/5] VFS: Convert drop_caches to accept string
Date: Mon, 16 Dec 2013 07:00:05 -0800
Message-Id: <95d2d9c42afac287d42eecb160569eac4c59d90a.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>


Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 kernel/sysctl.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 34a6047..2f2d8ab 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1255,12 +1255,10 @@ static struct ctl_table vm_table[] = {
 	},
 	{
 		.procname	= "drop_caches",
-		.data		= &sysctl_drop_caches,
-		.maxlen		= sizeof(int),
+		.data		= sysctl_drop_caches,
+		.maxlen		= PATH_MAX,
 		.mode		= 0644,
 		.proc_handler	= drop_caches_sysctl_handler,
-		.extra1		= &one,
-		.extra2		= &three,
 	},
 #ifdef CONFIG_COMPACTION
 	{
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
