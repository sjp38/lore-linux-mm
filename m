Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 0E90C6B004A
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 06:51:35 -0400 (EDT)
Message-ID: <1334487062.2528.113.camel@twins>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
From: Peter Zijlstra <peterz@infradead.org>
Date: Sun, 15 Apr 2012 12:51:02 +0200
In-Reply-To: <20120414205200.GA9083@redhat.com>
References: <20120405222024.GA19154@redhat.com>
	 <1334409396.2528.100.camel@twins> <20120414205200.GA9083@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Sat, 2012-04-14 at 22:52 +0200, Oleg Nesterov wrote:
> > >     - can it work or I missed something "in general" ?
> >
> > So we insert in the rb-tree before we take mmap_sem, this means we can
> > hit a non-uprobe int3 and still find a uprobe there, no?
>=20
> Yes, but unless I miss something this is "off-topic", this
> can happen with or without these changes. If find_uprobe()
> succeeds we assume that this bp was inserted by uprobe.

OK, but then I completely missed what the point of that=20
down_write() stuff is..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
