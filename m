Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2AE6B0005
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:09:04 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 62so653925iow.16
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:09:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j73sor825765itb.80.2018.02.15.08.09.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 08:09:03 -0800 (PST)
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH 1/3] percpu: match chunk allocator declarations with definitions
Date: Thu, 15 Feb 2018 10:08:14 -0600
Message-Id: <3865d86559d8499f9bbb12f578bf9e6aa8f8882e.1518668149.git.dennisszhou@gmail.com>
In-Reply-To: <cover.1518668149.git.dennisszhou@gmail.com>
References: <cover.1518668149.git.dennisszhou@gmail.com>
In-Reply-To: <cover.1518668149.git.dennisszhou@gmail.com>
References: <cover.1518668149.git.dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dennis Zhou <dennisszhou@gmail.com>

At some point the function declaration parameters got out of sync with
the function definitions in percpu-vm.c and percpu-km.c. This patch
makes them match again.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 50e7fdf..e1ea410 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1277,8 +1277,10 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
  * pcpu_addr_to_page		- translate address to physical address
  * pcpu_verify_alloc_info	- check alloc_info is acceptable during init
  */
-static int pcpu_populate_chunk(struct pcpu_chunk *chunk, int off, int size);
-static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk, int off, int size);
+static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
+			       int page_start, int page_end);
+static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
+				  int page_start, int page_end);
 static struct pcpu_chunk *pcpu_create_chunk(void);
 static void pcpu_destroy_chunk(struct pcpu_chunk *chunk);
 static struct page *pcpu_addr_to_page(void *addr);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
