Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 57CA46B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:05:58 -0500 (EST)
Date: Tue, 30 Nov 2010 14:05:53 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: [extra] timers: Use this_cpu_read
In-Reply-To: <20101130190707.457099608@linux.com>
Message-ID: <alpine.DEB.2.00.1011301404490.4039@router.home>
References: <20101130190707.457099608@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Subject: timers: Use this_cpu_read

Eric asked for this.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 kernel/timer.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/kernel/timer.c
===================================================================
--- linux-2.6.orig/kernel/timer.c	2010-11-30 14:01:41.000000000 -0600
+++ linux-2.6/kernel/timer.c	2010-11-30 14:02:05.000000000 -0600
@@ -1249,7 +1249,7 @@ static unsigned long cmp_next_hrtimer_ev
  */
 unsigned long get_next_timer_interrupt(unsigned long now)
 {
-	struct tvec_base *base = __get_cpu_var(tvec_bases);
+	struct tvec_base *base = __this_cpu_read(tvec_bases);
 	unsigned long expires;

 	spin_lock(&base->lock);
@@ -1292,7 +1292,7 @@ void update_process_times(int user_tick)
  */
 static void run_timer_softirq(struct softirq_action *h)
 {
-	struct tvec_base *base = __get_cpu_var(tvec_bases);
+	struct tvec_base *base = __this_cpu_read(tvec_bases);

 	hrtimer_run_pending();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
