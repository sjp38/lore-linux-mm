Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3A43B6B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 10:29:23 -0400 (EDT)
Date: Tue, 14 Jun 2011 16:27:10 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
	replacement.
Message-ID: <20110614142710.GB5139@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6> <20110613170020.GA27137@redhat.com> <1308056477.19856.35.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308056477.19856.35.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 06/14, Peter Zijlstra wrote:
>
> On Mon, 2011-06-13 at 19:00 +0200, Oleg Nesterov wrote:
> >
> > Also. This is called under down_read(mmap_sem), can't we race with
> > access_process_vm() modifying the same memory?
>
> Shouldn't matter COW and similar things are serialized using the pte
> lock.

Yes, but afaics this doesn't matter. Suppose that write_opcode() is
called when access_process_vm() does copy_to_user_page(). We can cow
the page before memcpy() completes.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
