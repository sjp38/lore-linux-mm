Subject: Re: 2.5.64-mm2
From: Robert Love <rml@tech9.net>
In-Reply-To: <1047096093.3483.4.camel@localhost.localdomain>
References: <20030307185116.0c53e442.akpm@digeo.com>
	 <1047095352.3483.0.camel@localhost.localdomain>
	 <1047096331.727.14.camel@phantasy.awol.org>
	 <1047096093.3483.4.camel@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1047097353.727.18.camel@phantasy.awol.org>
Mime-Version: 1.0
Date: 07 Mar 2003 23:22:33 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shawn <core@enodev.com>, Andrew Morton <akpm@digeo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-03-07 at 23:01, Shawn wrote:
> Here's my .config. I am not SMP.
> 
> I suspected the distclean thing, but I made "Mr. Proper" too just in
> case.

Oh.  Its those damn modules.  The bane of my existence.

Problem is, ksyms.c is exporting kernel_flag under PREEMPT.  Now we just
need it exported under SMP.

Andrew, would you mind appending this to the current patch? Sorry.

Everyone else, you need this if you are UP+PREEMPT+MODULES.

	Robert Love


 kernel/ksyms.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff -urN linux-2.5.64-mm2/kernel/ksyms.c linux/kernel/ksyms.c
--- linux-2.5.64-mm2/kernel/ksyms.c	2003-03-07 22:08:04.000000000 -0500
+++ linux/kernel/ksyms.c	2003-03-07 23:19:32.098500176 -0500
@@ -488,7 +488,7 @@
 #if CONFIG_SMP
 EXPORT_SYMBOL_GPL(set_cpus_allowed);
 #endif
-#if CONFIG_SMP || CONFIG_PREEMPT
+#if CONFIG_SMP
 EXPORT_SYMBOL(kernel_flag);
 #endif
 EXPORT_SYMBOL(jiffies);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
