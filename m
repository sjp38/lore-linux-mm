Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBB4900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:55:35 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@hack.frob.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 14/22] 14: x86: uprobes exception
 notifier for x86.
In-Reply-To: Srikar Dronamraju's message of  Wednesday, 22 June 2011 20:24:24 +0530 <20110622145424.GG16471@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	<20110607130101.28590.99984.sendpatchset@localhost6.localdomain6>
	<1308663084.26237.145.camel@twins>
	<1308663167.26237.146.camel@twins>
	<20110622145424.GG16471@linux.vnet.ibm.com>
Message-Id: <20110622164055.1F5162C11F@topped-with-meat.com>
Date: Wed, 22 Jun 2011 09:40:55 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

> Oleg, Roland, do you know why do_notify_resume() gets called with
> interrupts disabled on i386? 

It was that way for a long time.  My impression was that it was just not
bothering to reenable before do_signal->get_signal_to_deliver would shortly
disable (via spin_lock_irq) anyway.  It's possible there was something more
to it, but I don't know of anything.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
