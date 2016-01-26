From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 07/17] kexec: Set IORESOURCE_SYSTEM_RAM for System RAM
Date: Tue, 26 Jan 2016 21:57:23 +0100
Message-ID: <1453841853-11383-8-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kexec-bounces+glkk-kexec=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/kexec>,
 <mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/kexec/>
List-Post: <mailto:kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/kexec>,
 <mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "kexec" <kexec-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: kexec-bounces+glkk-kexec=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Baoquan He <bhe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, HATAYAMA Daisuke <d.hatayama-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Minfei Huang <mnfhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Dave Young <dyoung-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani-ZPxbGqLxI0U@public.gmane.org>

Set proper ioresource flags and types for crash kernel reservation
areas.

Reviewed-by: Dave Young <dyoung-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Toshi Kani <toshi.kani-ZPxbGqLxI0U@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Baoquan He <bhe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Dave Young <dyoung-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: HATAYAMA Daisuke <d.hatayama-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
Cc: Minfei Huang <mnfhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Link: http://lkml.kernel.org/r/1452020081-26534-7-git-send-email-toshi.kani-ZPxbGqLxI0U@public.gmane.org
Signed-off-by: Borislav Petkov <bp-l3A5Bk7waGM@public.gmane.org>
---
 kernel/kexec_core.c | 8 +++++---
 kernel/kexec_file.c | 2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 8dc659144869..8d34308ea449 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -66,13 +66,15 @@ struct resource crashk_res = {
 	.name  = "Crash kernel",
 	.start = 0,
 	.end   = 0,
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
+	.desc  = IORES_DESC_CRASH_KERNEL
 };
 struct resource crashk_low_res = {
 	.name  = "Crash kernel",
 	.start = 0,
 	.end   = 0,
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
+	.desc  = IORES_DESC_CRASH_KERNEL
 };
 
 int kexec_should_crash(struct task_struct *p)
@@ -959,7 +961,7 @@ int crash_shrink_memory(unsigned long new_size)
 
 	ram_res->start = end;
 	ram_res->end = crashk_res.end;
-	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
+	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
 	ram_res->name = "System RAM";
 
 	crashk_res.end = end - 1;
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index 007b791f676d..2bfcdc064116 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -525,7 +525,7 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
 	/* Walk the RAM ranges and allocate a suitable range for the buffer */
 	if (image->type == KEXEC_TYPE_CRASH)
 		ret = walk_iomem_res("Crash kernel",
-				     IORESOURCE_MEM | IORESOURCE_BUSY,
+				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
 				     crashk_res.start, crashk_res.end, kbuf,
 				     locate_mem_hole_callback);
 	else
-- 
2.3.5
