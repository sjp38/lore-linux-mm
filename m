Date: Mon, 5 May 2003 14:02:33 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm1
Message-ID: <20030505210233.GP8978@holomorphy.com>
References: <20030504231650.75881288.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030504231650.75881288.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 04, 2003 at 11:16:50PM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm1/
> Various random fixups, cleanps and speedups.  Mainly a resync to 2.5.69.

kernel/sched.c: In function `rebalance_tick':
kernel/sched.c:1352: warning: declaration of `this_cpu' shadows a parameter


diff -urpN mm1-2.5.69-1/kernel/sched.c mm1-2.5.69-2/kernel/sched.c
--- mm1-2.5.69-1/kernel/sched.c	2003-05-05 13:32:44.000000000 -0700
+++ mm1-2.5.69-2/kernel/sched.c	2003-05-05 13:37:28.000000000 -0700
@@ -1348,9 +1348,6 @@ static void balance_node(runqueue_t *thi
 
 static void rebalance_tick(runqueue_t *this_rq, int this_cpu, int idle)
 {
-#ifdef CONFIG_NUMA
-	int this_cpu = smp_processor_id();
-#endif
 	unsigned long j = jiffies;
 
 	/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
