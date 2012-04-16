Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 481E96B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:17:18 -0400 (EDT)
Message-ID: <1334571419.28150.30.camel@twins>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 16 Apr 2012 12:16:59 +0200
In-Reply-To: <20120415234401.GA32662@redhat.com>
References: <20120405222024.GA19154@redhat.com>
	 <1334409396.2528.100.camel@twins> <20120414205200.GA9083@redhat.com>
	 <1334487062.2528.113.camel@twins> <20120415195351.GA22095@redhat.com>
	 <1334526513.28150.23.camel@twins> <20120415234401.GA32662@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Mon, 2012-04-16 at 01:44 +0200, Oleg Nesterov wrote:

> No. Please note that if is_swbp_at_addr_fast() sets is_swbp =3D=3D 0 we
> restart this insn.

Ah, see I was missing something..  Hmm ok, let me think about this a
little more though.. but at least I think I'm now (finally!) seeing what
you propose.

> And. I have another reason for down_write() in register/unregister.
> I am still not sure this is possible (I had no time to try to
> implement), but it seems to me we can kill the uprobe counter in
> mm_struct.

You mean by making register/unregister down_write, you're exclusive with
munmap() and thus we can rely on is_swbp_at_addr_fast() to inspect the
address to see if there's a breakpoint or not and avoid the rest of the
work that way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
