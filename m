Subject: [KJ][PATCH]is_power_of_2-sparc/mm/srmmu.c
From: vignesh babu <vignesh.babu@wipro.com>
Reply-To: vignesh.babu@wipro.com
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 07 Jun 2007 15:27:43 +0530
Message-Id: <1181210263.11218.2.camel@merlin.linuxcoe.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com, davem@caip.rutgers.edu, zaitcev@yahoo.com, ecd@skynet.be, jj@sunsite.mff.cuni.cz, anton@samba.org
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Janitors List <kernel-janitors@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

Replacing (n & (n-1)) in the context of power of 2 checks
with is_power_of_2

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
--- 
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index e5eaa80..741d303 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -19,6 +19,7 @@
#include <linux/fs.h>
#include <linux/seq_file.h>
#include <linux/kdebug.h>
+#include <linux/log2.h>

#include <asm/bitext.h>
#include <asm/page.h>
@@ -354,7 +355,7 @@ void srmmu_free_nocache(unsigned long vaddr, int
size)
    vaddr, srmmu_nocache_end);
BUG();
}
- if (size & (size-1)) {
+ if (!is_power_of_2(size)) {
printk("Size 0x%x is not a power of 2\n", size);
BUG();
}

-- 
Vignesh Babu BM 
_____________________________________________________________ 
"Why is it that every time I'm with you, makes me believe in magic?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
