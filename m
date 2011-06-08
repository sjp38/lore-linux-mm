Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BACF6B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 03:05:28 -0400 (EDT)
Message-ID: <4DEF1F07.4000400@redhat.com>
Date: Wed, 08 Jun 2011 00:04:39 -0700
From: Josh Stone <jistone@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3.0-rc2-tip 3/22]  3: uprobes: Adding and remove a
 uprobe in a rb tree.
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125850.28590.10861.sendpatchset@localhost6.localdomain6> <20110608041217.GA4879@wicker.gateway.2wire.net>
In-Reply-To: <20110608041217.GA4879@wicker.gateway.2wire.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On 06/07/2011 09:12 PM, Stephen Wilson wrote:
> Also, changing the argument order seems to solve the issue reported by
> Josh Stone where only the uprobe with the lowest address was responding
> (thou I did not test with perf, just lightly with the trace_event
> interface).

Makes sense, and indeed after swapping the arguments to both calls, the
perf test I gave now works as expected.  Thanks!

Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
