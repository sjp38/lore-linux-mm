Subject: Re: Compile problem with CONFIG_X86_CYCLONE_TIMER Re:
	2.6.0-test3-mm2
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20030815203620.GO1027@matchmail.com>
References: <20030813013156.49200358.akpm@osdl.org>
	 <20030815193834.GL1027@matchmail.com> <20030815202322.GN1027@matchmail.com>
	 <20030815203620.GO1027@matchmail.com>
Content-Type: multipart/mixed; boundary="=-s2hh8Fv/6PQdVc4UFwto"
Message-Id: <1061065941.31662.35.camel@nighthawk>
Mime-Version: 1.0
Date: 16 Aug 2003 13:32:22 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-s2hh8Fv/6PQdVc4UFwto
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2003-08-15 at 13:36, Mike Fedyk wrote:
> On Fri, Aug 15, 2003 at 01:23:22PM -0700, Mike Fedyk wrote:
> > On Fri, Aug 15, 2003 at 12:38:34PM -0700, Mike Fedyk wrote:
> > > arch/i386/kernel/timers/timer_cyclone.c: In function `init_cyclone':
> > > arch/i386/kernel/timers/timer_cyclone.c:157: `FIX_CYCLONE_TIMER' undeclared (first use in this function)
> > > arch/i386/kernel/timers/timer_cyclone.c:157: (Each undeclared identifier is reported only once
> > > arch/i386/kernel/timers/timer_cyclone.c:157: for each function it appears in.)
> > >

I couldn't replicate the problem, but I suspect this fix is correct in
any case.  If this doesn't fix it, please post your config.  

John, I imagine that you probably haven't always had CONFIG_X86_CYCLONE,
and this was just a leftover from then.  

-- 
Dave Hansen
haveblue@us.ibm.com

--=-s2hh8Fv/6PQdVc4UFwto
Content-Disposition: attachment; filename=cyclone-fixmap-2.6.0-test3-mm2-0.patch
Content-Type: text/plain; name=cyclone-fixmap-2.6.0-test3-mm2-0.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

--- linux-2.6.0-test3-mm2-clean/include/asm-i386/fixmap.h	Sat Aug 16 13:18:22 2003
+++ linux-2.6.0-test3-mm2-cyclonefix/include/asm-i386/fixmap.h	Sat Aug 16 13:28:30 2003
@@ -73,7 +73,7 @@
 	FIX_TSS_0,
 	FIX_ENTRY_TRAMPOLINE_1,
 	FIX_ENTRY_TRAMPOLINE_0,
-#ifdef CONFIG_X86_SUMMIT
+#ifdef CONFIG_X86_CYCLONE
 	FIX_CYCLONE_TIMER, /*cyclone timer register*/
 	FIX_VSTACK_HOLE_2,
 #endif 

--=-s2hh8Fv/6PQdVc4UFwto--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
