Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CCF306B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 08:04:03 -0400 (EDT)
Message-ID: <4DF2082C.6070009@hitachi.com>
Date: Fri, 10 Jun 2011 21:03:56 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3.0-rc2-tip 22/22] 22: perf: Documentation for perf
 uprobes
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607130241.28590.87063.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607130241.28590.87063.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, yrl.pp-manager.tt@hitachi.com

(2011/06/07 22:02), Srikar Dronamraju wrote:
> Modify perf-probe.txt to include uprobe documentation

Sorry, Nak this. I hope to see better uniformed interface for
both of uprobe and kprobe, even after we support debuginfo for
uprobe.

I mean, if uprobe always requires a user-space binary, it should
be specified with -u option instead of --exe and @EXE.

I think this simplifies perf probe usage, it implies;

# perf probe [-k KERN] [...]  // Control probes in kernel
# perf probe -m MOD [...]     // Control probes in MOD module
# perf probe -u EXE [...]     // Control probes on EXE file

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
