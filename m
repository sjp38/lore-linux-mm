Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E37A6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 07:50:48 -0400 (EDT)
Message-ID: <4DF20511.8000206@hitachi.com>
Date: Fri, 10 Jun 2011 20:50:41 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3.0-rc2-tip 20/22] 20: perf: perf interface for uprobes
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, yrl.pp-manager.tt@hitachi.com

(2011/06/07 22:02), Srikar Dronamraju wrote:
> Enhances perf probe to user space executables and libraries.
> Provides very basic support for uprobes.
> 
> [ Probing a function in the executable using function name  ]
> -------------------------------------------------------------
> [root@localhost ~]# perf probe -u zfree@/bin/zsh

Hmm, here, I have concern about the interface inconsistency
of the probe point syntax.

Since perf probe already supports debuginfo analysis,
it accepts following syntax;

[EVENT=]FUNC[@SRC][:RLN|+OFFS|%return|;PTN] [ARG ...]

Thus, The "@" should take a source file path, not binary path.

I think -u option should have a path of the target binary, as below

# perf probe -u /bin/zsh -a zfree

This will allow perf-probe to support user-space debuginfo
analysis. With it, we can do as below;

# perf probe -u /bin/zsh -a zfree@foo/bar.c:10

Please try to update tools/perf/Documentation/perf-probe.txt too,
then you'll see how the new syntax is different from current one :)

Thanks,



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
