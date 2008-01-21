Message-Id: <20080121202748.047065000@sgi.com>
References: <20080121202747.593568000@sgi.com>
Date: Mon, 21 Jan 2008 12:27:50 -0800
From: travis@sgi.com
Subject: [PATCH 3/8] pecpu: Fix size of percpu_data.ptrs array rc8-mm1-fixup
Content-Disposition: inline; filename=generic-percpu-fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Define the size of the generic percpu pointers array to be NR_CPUS

Based on: 2.6.24-rc8-mm1

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
 include/linux/percpu.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -58,7 +58,7 @@
 #ifdef CONFIG_SMP
 
 struct percpu_data {
-	void *ptrs[1];
+	void *ptrs[NR_CPUS];
 };
 
 #define __percpu_disguise(pdata) (struct percpu_data *)~(unsigned long)(pdata)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
