Date: Thu, 22 May 2003 07:55:31 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm8
Message-ID: <20030522145531.GR8978@holomorphy.com>
References: <20030522021652.6601ed2b.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030522021652.6601ed2b.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 22, 2003 at 02:16:52AM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm8/
> . One anticipatory scheduler patch, but it's a big one.  I have not stress
>   tested it a lot.  If it explodes please report it and then boot with
>   elevator=deadline.
> . The slab magazine layer code is in its hopefully-final state.
> . Some VFS locking scalability work - stress testing of this would be
>   useful.


Looks like this bit fell out from mainline; required for CONFIG_NUMA
to compile and identical to mainline.

-- wli

diff -prauN mm8-2.5.69-1/kernel/sched.c mm8-2.5.69-2/kernel/sched.c
--- mm8-2.5.69-1/kernel/sched.c	2003-05-22 04:54:59.000000000 -0700
+++ mm8-2.5.69-2/kernel/sched.c	2003-05-22 07:35:01.000000000 -0700
@@ -1084,6 +1084,9 @@ static void balance_node(runqueue_t *thi
 
 static void rebalance_tick(runqueue_t *this_rq, int idle)
 {
+#ifdef CONFIG_NUMA
+	int this_cpu = smp_processor_id();
+#endif
 	unsigned long j = jiffies;
 
 	/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
