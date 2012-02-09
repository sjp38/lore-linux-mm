Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E27816B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 03:27:03 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 9 Feb 2012 03:27:02 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7938138C8026
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 03:27:01 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q198R11Q232330
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 03:27:01 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q198QwX3012732
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 03:27:01 -0500
Date: Thu, 9 Feb 2012 13:44:51 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: Re: [PATCH v10 3.3-rc2 1/9] uprobes: Install and remove
 breakpoints.
Message-ID: <20120209081451.GC16600@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
 <20120202141851.5967.68000.sendpatchset@srdronam.in.ibm.com>
 <20120207171707.GA24443@linux.vnet.ibm.com>
 <CAK1hOcOd3hd31vZYw1yAVGK=gMV=vQotL1mRZkVgM=7M8mbMyw@mail.gmail.com>
 <4F3320E5.1050707@hitachi.com>
 <20120209063745.GB16600@linux.vnet.ibm.com>
 <20120209075357.GD18387@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120209075357.GD18387@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Denys Vlasenko <vda.linux@googlemail.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

* Ingo Molnar <mingo@elte.hu> [2012-02-09 08:53:57]:

> 
> * Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:
> 
> > 	/* Clear REX.b bit (extension of MODRM.rm field):
> > 	 * we want to encode rax/rcx, not r8/r9.
> > 	 */
> 
> Small stylistic nit, just saw this chunk fly by - the proper 
> comment style is like this one:

Okay, Will correct that in the patch that I send.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
