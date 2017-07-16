Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27C2C6B0594
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z1so135200985pgs.10
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:36 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f31si5968856plf.393.2017.07.15.19.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:35 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 01/10] percpu: pcpu-stats change void buffer to int buffer
Date: Sat, 15 Jul 2017 22:23:06 -0400
Message-ID: <20170716022315.19892-2-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Changes the use of a void buffer to an int buffer for clarity.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-stats.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 03524a5..0d81044 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -49,7 +49,7 @@ static int find_max_map_used(void)
  * the beginning of the chunk to the last allocation.
  */
 static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
-			    void *buffer)
+			    int *buffer)
 {
 	int i, s_index, last_alloc, alloc_sign, as_len;
 	int *alloc_sizes, *p;
@@ -113,7 +113,7 @@ static int percpu_stats_show(struct seq_file *m, void *v)
 {
 	struct pcpu_chunk *chunk;
 	int slot, max_map_used;
-	void *buffer;
+	int *buffer;
 
 alloc_buffer:
 	spin_lock_irq(&pcpu_lock);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
