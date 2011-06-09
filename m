Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBD06B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 18:59:51 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QUoCa-00066Q-4Y
	for linux-mm@kvack.org; Thu, 09 Jun 2011 22:59:48 +0000
Subject: Re: [PATCH v4 3.0-rc2-tip 5/22]  5: x86: analyze instruction and
 determine fixups.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607125911.28590.41526.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125911.28590.41526.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Jun 2011 01:03:19 +0200
Message-ID: <1307660599.2497.1761.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-06-07 at 18:29 +0530, Srikar Dronamraju wrote:
> +static void report_bad_prefix(void)
> +{
> +       pr_warn_once("uprobes does not currently support probing "
> +               "instructions with any of the following prefixes: "
> +               "cs:, ds:, es:, ss:, lock:\n");
> +}
> +
> +static void report_bad_1byte_opcode(int mode, uprobe_opcode_t op)
> +{
> +       pr_warn_once("In %d-bit apps, "
> +               "uprobes does not currently support probing "
> +               "instructions whose first byte is 0x%2.2x\n", mode, op);
> +}
> +
> +static void report_bad_2byte_opcode(uprobe_opcode_t op)
> +{
> +       pr_warn_once("uprobes does not currently support probing "
> +               "instructions with the 2-byte opcode 0x0f 0x%2.2x\n", op);
> +} 

I really don't like all that dmesg muck, why not simply fail the op?

This _once stuff is pretty useless too, once you've had them all
subsequent probe attempts will not say anything and leave you in the
dark anyway.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
