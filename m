From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 00/18] Upgrade of this_cpu_ops V3
Date: Tue, 30 Nov 2010 13:07:07 -0600
Message-ID: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZF-00009N-JO
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:08:45 +0100
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B9BF6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:43 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

A patchset that adds more this_cpu operations and in particular RMV operations
that can be used in various places to avoid address calculations and
memory accesses by the user of fast cpu local operations with segment
prefixes.

V2 has several enhancements and bugfixes that were suggested after V1

V3 removes the cmpxchg patches and focuses on the first extensions
of cpu ops that were generally an improvement.

For V3 I scanned through the kernel code for obvious cases in which a
__get_cpu_var or get_cpu_var can be converted to this_cpu_ops. That is
often not possible because addresses of per cpu variables are needed.
However, the accesses that could become converted became very cheap
because this_cpu_ops typically only generate a single instruction using
a segment prefix to perform the relocation to the correct per cpu area.

Cpu ops perform implied address calculations. It is therefore not possible
to take the address of the result of a this_cpu_xx operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
