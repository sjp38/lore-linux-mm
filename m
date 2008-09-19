Message-ID: <48D40C43.5070200@linux-foundation.org>
Date: Fri, 19 Sep 2008 15:32:03 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 3/4] cpu alloc: The allocator
References: <20080919145859.062069850@quilx.com> <20080919145929.158651064@quilx.com>
In-Reply-To: <20080919145929.158651064@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Duh. A cast went missing which results in a pointer calculation going haywire.

Signed-off-by: <cl@linux-foundation.org>

Index: linux-2.6/mm/cpu_alloc.c
===================================================================
--- linux-2.6.orig/mm/cpu_alloc.c	2008-09-19 14:57:25.000000000 -0500
+++ linux-2.6/mm/cpu_alloc.c	2008-09-19 14:57:33.000000000 -0500
@@ -126,7 +126,7 @@

 	spin_unlock_irqrestore(&cpu_alloc_map_lock, flags);

-	ptr = __per_cpu_end + start;
+	ptr = (int *)__per_cpu_end + start;

 	printk(KERN_INFO "%d per cpu units allocated at offset %lx address %p\n",
 		units, start, ptr)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
