Date: Wed, 16 Jul 2003 15:36:52 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test1-mm1
Message-ID: <20030716223652.GO15452@holomorphy.com>
References: <20030715225608.0d3bff77.akpm@osdl.org> <20030716220235.GC1821@matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030716220235.GC1821@matchmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 16, 2003 at 03:02:36PM -0700, Mike Fedyk wrote:
> Hi there.
> I'm having some trouble compiling -mm1
> It looks like it's from the ACPI update.
> More info available upon request.
> gcc version 2.95.4 20011002 (Debian prerelease)


diff -prauN mm1-2.6.0-test1-1/arch/i386/mach-generic/bigsmp.c mm1-2.6.0-test1-2/arch/i386/mach-generic/bigsmp.c
--- mm1-2.6.0-test1-1/arch/i386/mach-generic/bigsmp.c	2003-07-16 15:22:42.000000000 -0700
+++ mm1-2.6.0-test1-2/arch/i386/mach-generic/bigsmp.c	2003-07-16 15:29:04.000000000 -0700
@@ -6,6 +6,7 @@
 #include <linux/config.h>
 #include <linux/threads.h>
 #include <linux/cpumask.h>
+#include <asm/mpspec.h>
 #include <asm/genapic.h>
 #include <asm/fixmap.h>
 #include <asm/apicdef.h>
diff -prauN mm1-2.6.0-test1-1/arch/i386/mach-generic/default.c mm1-2.6.0-test1-2/arch/i386/mach-generic/default.c
--- mm1-2.6.0-test1-1/arch/i386/mach-generic/default.c	2003-07-16 15:22:42.000000000 -0700
+++ mm1-2.6.0-test1-2/arch/i386/mach-generic/default.c	2003-07-16 15:29:23.000000000 -0700
@@ -5,6 +5,7 @@
 #include <linux/config.h>
 #include <linux/threads.h>
 #include <linux/cpumask.h>
+#include <asm/mpspec.h>
 #include <asm/mach-default/mach_apicdef.h>
 #include <asm/genapic.h>
 #include <asm/fixmap.h>
diff -prauN mm1-2.6.0-test1-1/arch/i386/mach-generic/probe.c mm1-2.6.0-test1-2/arch/i386/mach-generic/probe.c
--- mm1-2.6.0-test1-1/arch/i386/mach-generic/probe.c	2003-07-16 15:22:42.000000000 -0700
+++ mm1-2.6.0-test1-2/arch/i386/mach-generic/probe.c	2003-07-16 15:27:27.000000000 -0700
@@ -11,6 +11,7 @@
 #include <linux/ctype.h>
 #include <linux/init.h>
 #include <asm/fixmap.h>
+#include <asm/mpspec.h>
 #include <asm/apicdef.h>
 #include <asm/genapic.h>
 
diff -prauN mm1-2.6.0-test1-1/arch/i386/mach-generic/summit.c mm1-2.6.0-test1-2/arch/i386/mach-generic/summit.c
--- mm1-2.6.0-test1-1/arch/i386/mach-generic/summit.c	2003-07-16 15:22:42.000000000 -0700
+++ mm1-2.6.0-test1-2/arch/i386/mach-generic/summit.c	2003-07-16 15:28:29.000000000 -0700
@@ -5,6 +5,7 @@
 #include <linux/config.h>
 #include <linux/threads.h>
 #include <linux/cpumask.h>
+#include <asm/mpspec.h>
 #include <asm/genapic.h>
 #include <asm/fixmap.h>
 #include <asm/apicdef.h>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
