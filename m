Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C5ED46B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:21:35 -0400 (EDT)
Date: Tue, 7 Jun 2011 11:21:16 -0300
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH v4 3.0-rc2-tip 20/22] 20: perf: perf interface for uprobes
Message-ID: <20110607142116.GA8311@ghostprotocols.net>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6>
 <20110607133039.GA4929@infradead.org>
 <20110607133853.GC9949@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607133853.GC9949@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

Em Tue, Jun 07, 2011 at 07:08:53PM +0530, Ananth N Mavinakayanahalli escreveu:
> On Tue, Jun 07, 2011 at 09:30:39AM -0400, Christoph Hellwig wrote:
> > On Tue, Jun 07, 2011 at 06:32:16PM +0530, Srikar Dronamraju wrote:
> > > Enhances perf probe to user space executables and libraries.
> > > Provides very basic support for uprobes.

> > Nice.  Does this require full debug info for symbolic probes,
> > or can it also work with simple symbolc information?
 
> It works only with symbol information for now.
> It doesn't (yet) know how to use debuginfo :-)

'perf probe' uses perf symbol library, so it really don't have to know
from where symbol resolution information is obtained, only if it needs
things that are _just_ on debuginfo, such as line information, etc.

But then that is also already supported in 'perf probe'.

Or is there something else in particular you're thinking?

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
