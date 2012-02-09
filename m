Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id A508B6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 02:54:28 -0500 (EST)
Date: Thu, 9 Feb 2012 08:53:57 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Re: [PATCH v10 3.3-rc2 1/9] uprobes: Install and remove
 breakpoints.
Message-ID: <20120209075357.GD18387@elte.hu>
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
 <20120202141851.5967.68000.sendpatchset@srdronam.in.ibm.com>
 <20120207171707.GA24443@linux.vnet.ibm.com>
 <CAK1hOcOd3hd31vZYw1yAVGK=gMV=vQotL1mRZkVgM=7M8mbMyw@mail.gmail.com>
 <4F3320E5.1050707@hitachi.com>
 <20120209063745.GB16600@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120209063745.GB16600@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Denys Vlasenko <vda.linux@googlemail.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com


* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> 	/* Clear REX.b bit (extension of MODRM.rm field):
> 	 * we want to encode rax/rcx, not r8/r9.
> 	 */

Small stylistic nit, just saw this chunk fly by - the proper 
comment style is like this one:

> 	/*
> 	 * Point cursor at the modrm byte.  The next 4 bytes are the
> 	 * displacement.  Beyond the displacement, for some instructions,
> 	 * is the immediate operand.
> 	 */

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
