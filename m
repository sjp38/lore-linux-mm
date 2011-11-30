Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CD8146B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:15:13 -0500 (EST)
Message-ID: <91601168bd8039233da8d91a07560f20.squirrel@www.firstfloor.org>
In-Reply-To: <20111129182643.GB7339@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
    <20111128190614.GA4602@redhat.com>
    <20111129103040.GF13445@linux.vnet.ibm.com>
    <20111129182643.GB7339@redhat.com>
Date: Wed, 30 Nov 2011 17:15:10 +0100
Subject: Re: [PATCH RFC 0/5] uprobes: kill xol vma
From: "Andi Kleen" <andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


>  static unsigned char
> -uprobe_xol_slots[UPROBES_XOL_SLOT_BYTES][NR_CPUS] __page_aligned_bss;
> +uprobe_xol_slots[NR_CPUS][UPROBES_XOL_SLOT_BYTES] __page_aligned_bss;

NR_CPUS arrays are basically always wrong.

Use per cpu data.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
