Date: Mon, 26 Jun 2006 11:09:33 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [rfc][patch] fixes for several oom killer problems
Message-Id: <20060626110933.8fe47858.pj@sgi.com>
In-Reply-To: <20060626162038.GB7573@wotan.suse.de>
References: <20060626162038.GB7573@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, dsp@llnl.gov
List-ID: <linux-mm.kvack.org>

Acked-by: Paul Jackson <pj@sgi.com>

+	/*
+	 * If p's nodes don't overlap ours, it may still help to kill p
+	 * because p may have allocated or otherwise mapped memory on
+	 * this node before. However it will be less likely.
+	 */
+	if (!cpuset_excl_nodes_overlap(p))
+		points /= 4;

Good.


 int cpuset_excl_nodes_overlap(const struct task_struct *p)
 {
 	const struct cpuset *cs1, *cs2;	/* my and p's cpuset ancestors */
-	int overlap = 0;		/* do cpusets overlap? */
+	int overlap = 1;		/* do cpusets overlap? */

Good.

Thanks, Nick and Jan.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
