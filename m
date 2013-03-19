Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id F04356B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 23:52:25 -0400 (EDT)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH] kernel/range.c: subtract_range: fix the broken phrase issued by printk
Date: Tue, 19 Mar 2013 11:54:11 +0800
Message-Id: <1363665251-14377-1-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <CAE9FiQUrt11A0YAOLgvv3uTAWtTvVg3Mho9eD53orbxW6Jd8Vg@mail.gmail.com>
References: <CAE9FiQUrt11A0YAOLgvv3uTAWtTvVg3Mho9eD53orbxW6Jd8Vg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bhelgaas@google.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, yinghai@kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

Also replace deprecated printk(KERN_ERR...) with pr_err() as suggested
by Yinghai, attaching the function name to provide plenty info.

Cc: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 kernel/range.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/range.c b/kernel/range.c
index 9b8ae2d..071b0ab 100644
--- a/kernel/range.c
+++ b/kernel/range.c
@@ -97,7 +97,8 @@ void subtract_range(struct range *range, int az, u64 start, u64 end)
 				range[i].end = range[j].end;
 				range[i].start = end;
 			} else {
-				printk(KERN_ERR "run of slot in ranges\n");
+				pr_err("%s: run out of slot in ranges\n",
+					__func__);
 			}
 			range[j].end = start;
 			continue;
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
