Message-ID: <48519FDF.6010007@gmail.com>
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit
 architectures
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>	<4850070F.6060305@gmail.com>	<20080611121510.d91841a3.akpm@linux-foundation.org>	<485032C8.4010001@gmail.com>	<20080611134323.936063d3.akpm@linux-foundation.org>	<485055FF.9020500@gmail.com>	<20080611155530.099a54d6.akpm@linux-foundation.org>	<4850BE9B.5030504@linux.vnet.ibm.com>	<4850E3BC.308@gmail.com> <20080612020235.29a81d7c.akpm@linux-foundation.org> <485156B8.5070709@gmail.com>
In-Reply-To: <485156B8.5070709@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Jun 2008 00:14:53 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrea Righi wrote:
> I've tested the following patch on a i386 box with my usual .config and
> everything seems fine. I also tested allmodconfig and some randconfig builds and
> I've not seen any evident error.
> 
> I'll repeat the tests tonight on a x86_64. Other architectures should be tested
> as well...

x86_64 allmodconfig build failed due to a missing #include <linux/mm.h>
in arch/x86/kernel/module_64.c.

Following patch resolves (on top of the previous one).

Except this, no errors for x86_64.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
diff -urpN linux-2.6.25-rc5-mm3/arch/x86/kernel/module_64.c linux-2.6.25-rc5-mm3-fix-64-bit-page-align/arch/x86/kernel/module_64.c
--- linux-2.6.25-rc5-mm3/arch/x86/kernel/module_64.c	2008-06-13 00:05:51.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/arch/x86/kernel/module_64.c	2008-06-13 00:06:21.000000000 +0200
@@ -22,6 +22,7 @@
 #include <linux/fs.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/bug.h>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
