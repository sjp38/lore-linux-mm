Date: Tue, 23 Dec 2003 10:29:07 -0700
From: Tom Rini <trini@kernel.crashing.org>
Subject: Re: 2.6.0-mm1
Message-ID: <20031223172907.GF26574@stop.crashing.org>
References: <20031222211131.70a963fb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031222211131.70a963fb.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 22, 2003 at 09:11:31PM -0800, Andrew Morton wrote:

[snip]
> moto-ppc32-booting-fix.patch
>   Fix booting on a number of Motorola PPC32 machines

The following, based on comments from Keith Owens is better, please
replace, thanks:
===== arch/ppc/boot/simple/Makefile 1.23 vs edited =====
--- 1.23/arch/ppc/boot/simple/Makefile	Mon Sep 15 01:01:24 2003
+++ edited/arch/ppc/boot/simple/Makefile	Tue Dec 23 09:58:53 2003
@@ -76,6 +76,7 @@
 # The rest will be unset.
 motorola := $(CONFIG_MCPN765)$(CONFIG_MVME5100)$(CONFIG_PRPMC750) \
 $(CONFIG_PRPMC800)$(CONFIG_LOPEC)$(CONFIG_PPLUS)
+motorola := $(strip $(motorola))
 pcore := $(CONFIG_PCORE)$(CONFIG_POWERPMC250)
 
       zimage-$(motorola)		:= zImage-PPLUS


-- 
Tom Rini
http://gate.crashing.org/~trini/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
