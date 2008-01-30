Message-Id: <20080130180940.369732000@sgi.com>
References: <20080130180940.022172000@sgi.com>
Date: Wed, 30 Jan 2008 10:09:42 -0800
From: travis@sgi.com
Subject: [PATCH 2/6] percpu: Change Kconfig to HAVE_SETUP_PER_CPU_AREA linux-2.6.git
Content-Disposition: inline; filename=change-configs
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, mingo@elte.hu, Thomas Gleixner <tglx@linutronix.de>, config@kvack.org, HAVE_SETUP_PER_CPU_AREA@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Tony Luck <tony.luck@intel.com>, David Miller <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>, Rusty Russell <rusty@rustcorp.com.au>, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Based on latest linux-2.6.git

Cc: Andi Kleen <ak@suse.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: David Miller <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Cc: linuxppc-dev@ozlabs.org
Cc: linux-ia64@vger.kernel.org

Signed-off-by: Mike Travis <travis@sgi.com>
---
linux-2.6.git:
  - added back in missing pieces from x86.git merge

The change to using "select xxx" as suggested by Sam
requires an addition to a non-existant file (arch/Kconfig)
so I went back to using "config xxx" to introduce the flag.

---
 arch/ia64/Kconfig    |    2 +-
 arch/powerpc/Kconfig |    2 +-
 arch/sparc64/Kconfig |    2 +-
 init/main.c          |    2 ++
 4 files changed, 5 insertions(+), 3 deletions(-)

--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -80,7 +80,7 @@ config GENERIC_TIME_VSYSCALL
 	bool
 	default y
 
-config ARCH_SETS_UP_PER_CPU_AREA
+config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
 config DMI
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -42,7 +42,7 @@ config GENERIC_HARDIRQS
 	bool
 	default y
 
-config ARCH_SETS_UP_PER_CPU_AREA
+config HAVE_SETUP_PER_CPU_AREA
 	def_bool PPC64
 
 config IRQ_PER_CPU
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -66,7 +66,7 @@ config AUDIT_ARCH
 	bool
 	default y
 
-config ARCH_SETS_UP_PER_CPU_AREA
+config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
 config ARCH_NO_VIRT_TO_BUS
--- a/init/main.c
+++ b/init/main.c
@@ -380,6 +380,8 @@ static void __init setup_per_cpu_areas(v
 
 	/* Copy section for each CPU (we discard the original) */
 	size = ALIGN(PERCPU_ENOUGH_ROOM, PAGE_SIZE);
+	printk(KERN_INFO
+	    "PERCPU: Allocating %lu bytes of per cpu data (main)\n", size);
 	ptr = alloc_bootmem_pages(size * nr_possible_cpus);
 
 	for_each_possible_cpu(i) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
