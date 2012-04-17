Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 3DF516B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 15:54:03 -0400 (EDT)
Message-ID: <1334692418.28150.88.camel@twins>
Subject: Re: [PATCH 2/6] uprobes: introduce is_swbp_at_addr_fast()
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 17 Apr 2012 21:53:38 +0200
In-Reply-To: <20120417170958.GA16511@redhat.com>
References: <20120405222024.GA19154@redhat.com>
	 <20120405222106.GB19166@redhat.com> <1334570935.28150.25.camel@twins>
	 <20120416144457.GA7018@redhat.com> <1334588109.28150.59.camel@twins>
	 <20120416153408.GA8852@redhat.com> <1334657287.28150.77.camel@twins>
	 <20120417170958.GA16511@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Tue, 2012-04-17 at 19:09 +0200, Oleg Nesterov wrote:
>=20
> This reminds me. Why read_opcode() does lock_page? I was going
> to send the cleanup which removes it, but I need to recheck.
>=20
> Perhaps you can explain the reason?=20

I can't seem to recall, I suspect its to serialize against
__replace_page(). I can't say if that's strictly needed though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
