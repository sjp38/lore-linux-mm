Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 172F56B009F
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 05:16:07 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id w5so1868881qac.34
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:16:06 -0800 (PST)
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net. [2001:4b98:c:538::198])
        by mx.google.com with ESMTPS id ca6si92648qcb.95.2014.02.26.02.16.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 02:16:06 -0800 (PST)
Date: Wed, 26 Feb 2014 02:15:56 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH] ia64: select CONFIG_TTY for use of tty_write_message in
 unaligned
Message-ID: <20140226101556.GA23751@thin>
References: <530d8dd5.N73la/TcxHdsINPu%fengguang.wu@intel.com>
 <20140226070745.GA8078@thin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140226070745.GA8078@thin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

arch/ia64/kernel/unaligned.c uses tty_write_message to print an
unaligned access exception to the TTY of the current user process.
Enable TTY to prevent a build error.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
Not tested, but this *should* fix the build error with CONFIG_TTY=n.

Minimal fix, on the basis that few people on ia64 will care deeply about
kernel size enough to turn off TTY.  Ideally, I'd instead suggest
dropping the tty_write_message entirely, and just leaving the printk.
Bonus: no need to sprintf first.

 arch/ia64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 0c8e553..6b83c66 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -44,6 +44,7 @@ config IA64
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select TTY
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
