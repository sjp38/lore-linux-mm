Date: Thu, 1 Jan 2004 21:53:46 +0800
From: Eugene Teo <eugene.teo@eugeneteo.net>
Subject: Re: 2.6.0-rc1-mm1
Message-ID: <20040101135346.GA17781@eugeneteo.net>
Reply-To: Eugene Teo <eugene.teo@eugeneteo.net>
References: <20031231004725.535a89e4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031231004725.535a89e4.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, levon@movementarian.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

<quote sender="Andrew Morton">
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-rc1/2.6.0-rc1-mm1/

[snip]

> +make-for_each_cpu-iterator-more-friendly.patch

Trivial patch.

http://www.anomalistic.org/patches/oprofile-cpu_possible-fix-2.6.1-rc1-mm1.patch

diff -Naur -X /home/amnesia/w/dontdiff 2.6.1-rc1-mm1/drivers/oprofile/oprofile_stats.c 2.6.1-rc1-mm1-fix/drivers/oprofile/oprofile_stats.c
--- 2.6.1-rc1-mm1/drivers/oprofile/oprofile_stats.c	2004-01-01 20:29:19.000000000 +0800
+++ 2.6.1-rc1-mm1-fix/drivers/oprofile/oprofile_stats.c	2004-01-01 21:34:48.000000000 +0800
@@ -8,7 +8,7 @@
  */
 
 #include <linux/oprofile.h>
-#include <linux/smp.h>
+#include <linux/cpumask.h>
 #include <linux/threads.h>
  
 #include "oprofile_stats.h"

-- 
Eugene TEO   <eugeneteo@eugeneteo.net>   <http://www.anomalistic.org/>
1024D/14A0DDE5 print D851 4574 E357 469C D308  A01E 7321 A38A 14A0 DDE5
main(i) { putchar(182623909 >> (i-1) * 5&31|!!(i<7)<<6) && main(++i); }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
