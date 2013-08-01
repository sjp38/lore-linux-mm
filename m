Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id CB0156B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 18:33:34 -0400 (EDT)
Date: Thu, 1 Aug 2013 18:33:03 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] mm, numa: Change page last {nid,pid} into {cpu,pid}
Message-ID: <20130801183303.18880ad4@annuminas.surriel.com>
In-Reply-To: <20130730112438.GQ3008@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
	<20130730112438.GQ3008@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 30 Jul 2013 13:24:39 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> 
> Subject: mm, numa: Change page last {nid,pid} into {cpu,pid}
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Thu Jul 25 18:44:50 CEST 2013
> 
> Change the per page last fault tracking to use cpu,pid instead of
> nid,pid. This will allow us to try and lookup the alternate task more
> easily.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>

Here are some compile fixes for !CONFIG_NUMA_BALANCING

Signed-off-by: Rik van Riel <riel@redhat.com>

---
 include/linux/mm.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d2f91a2..4f34a37 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -746,7 +746,12 @@ static inline int cpupid_to_pid(int cpupid)
 	return -1;
 }
 
-static inline int nid_pid_to_cpupid(int nid, int pid)
+static inline int cpupid_to_cpu(int cpupid)
+{
+	return -1;
+}
+
+static inline int cpu_pid_to_cpupid(int nid, int pid)
 {
 	return -1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
