Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 5125C6B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:01:57 -0400 (EDT)
Message-ID: <4F86D241.1030609@hitachi.com>
Date: Thu, 12 Apr 2012 22:01:53 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] perf/probe: verify instruction/offset in perf before
 adding a uprobe
References: <20120412085748.23484.53789.stgit@nprashan.in.ibm.com> <4F86A060.1010604@linux.vnet.ibm.com>
In-Reply-To: <4F86A060.1010604@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

(2012/04/12 18:29), Prashanth Nageshappa wrote:
> To verify instruction/offset in perf, before adding a uprobe we
> need to use arc/x86/lib/insn.c from perf code. Since perf Makefile
> enables -Wswitch-default flag it causes build warnings/failures. This
> patch is to address the build warnings in insn.c.

Hmm, I see the reason why we need this. However, I think it should have
more correct error checking... I'll try that.

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
