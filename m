Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ABF938D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:29:13 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 7/26]  7: x86: analyze instruction
 and determine fixups.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110401143348.15455.68644.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143348.15455.68644.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 19 Apr 2011 09:29:11 -0400
Message-ID: <1303219751.7181.101.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-04-01 at 20:03 +0530, Srikar Dronamraju wrote:

> +
> +static void report_bad_prefix(void)
> +{
> +	printk(KERN_ERR "uprobes does not currently support probing "
> +		"instructions with any of the following prefixes: "
> +		"cs:, ds:, es:, ss:, lock:\n");
> +}
> +
> +static void report_bad_1byte_opcode(int mode, uprobe_opcode_t op)
> +{
> +	printk(KERN_ERR "In %d-bit apps, "
> +		"uprobes does not currently support probing "
> +		"instructions whose first byte is 0x%2.2x\n", mode, op);
> +}
> +
> +static void report_bad_2byte_opcode(uprobe_opcode_t op)
> +{
> +	printk(KERN_ERR "uprobes does not currently support probing "
> +		"instructions with the 2-byte opcode 0x0f 0x%2.2x\n", op);
> +}

Should these really be KERN_ERR, or is KERN_WARNING a better fit?

Also, can a non-privileged user cause these printks to spam the console
and cause a DoS to the system?

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
