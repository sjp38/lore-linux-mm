Subject: [PATCH] linux-2.6.0-test9-mm3_verbose-timesource-acpi-pm_A0
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <20031112233002.436f5d0c.akpm@osdl.org>
References: <20031112233002.436f5d0c.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1068753832.11438.1685.camel@cog.beaverton.ibm.com>
Mime-Version: 1.0
Date: 13 Nov 2003 12:03:53 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-11-12 at 23:30, Andrew Morton wrote:
> +acpi-pm-timer.patch
> +acpi-pm-timer-fixes.patch
> 
>  Yet another timer source for ia32
> 
[snip]
> verbose-timesource.patch
>   be verbose about the time source

Andrew, 
	I forgot that I sent you the verbose-timesource patch. The ACPI PM time
source will need this simple fix to work along side that patch.

thanks
-john

===== arch/i386/kernel/timers/timer_pm.c 1.6 vs edited =====
--- 1.6/arch/i386/kernel/timers/timer_pm.c	Tue Nov  4 11:39:50 2003
+++ edited/arch/i386/kernel/timers/timer_pm.c	Thu Nov 13 11:12:23 2003
@@ -185,6 +185,7 @@
 
 /* acpi timer_opts struct */
 struct timer_opts timer_pmtmr = {
+	.name			= "pmtmr",
 	.init 			= init_pmtmr,
 	.mark_offset		= mark_offset_pmtmr, 
 	.get_offset		= get_offset_pmtmr,



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
