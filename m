From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051110090941.8083.93120.sendpatchset@cherry.local>
In-Reply-To: <20051110090920.8083.54147.sendpatchset@cherry.local>
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
Subject: [PATCH 04/05] x86_64: NUMA without SMP
Date: Thu, 10 Nov 2005 18:08:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, pj@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Remove the SMP dependency from NUMA on x86_64.

This simple change is boot tested on real x86_64 NUMA hardware and in QEMU. 
Works with CONFIG_NUMA_EMU, CONFIG_K8_NUMA and CONFIG_ACPI_NUMA. This change
has earlier been discussed with Andi Kleen and rejected, but it is included
in this patch set for completeness.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 Kconfig |    1 -
 1 files changed, 1 deletion(-)

--- from-0002/arch/x86_64/Kconfig
+++ to-0005/arch/x86_64/Kconfig	2005-11-08 21:26:03.000000000 +0900
@@ -228,7 +228,6 @@ source "kernel/Kconfig.preempt"
 
 config NUMA
        bool "Non Uniform Memory Access (NUMA) Support"
-       depends on SMP
        help
 	 Enable NUMA (Non Uniform Memory Access) support. The kernel 
 	 will try to allocate memory used by a CPU on the local memory 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
