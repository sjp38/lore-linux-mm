Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0706B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 08:36:05 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 13/22] 13: uprobes: Handing int3 and
 singlestep exception.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110616120442.GA4093@linux.vnet.ibm.com>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
	 <1308225141.13240.25.camel@twins>
	 <20110616120442.GA4093@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Jun 2011 14:35:24 +0200
Message-ID: <1308227724.13240.58.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-06-16 at 17:34 +0530, Srikar Dronamraju wrote:
> > > +
> > > +cleanup_ret:
> > > +       if (u) {
> > > +               down_read(&mm->mmap_sem);
> > > +               if (!set_orig_insn(current, u, probept, true))
> >=20
> > we try to undo the probe? That doesn't make any sense. I thought you
> > meant to return to userspace, let it re-take the trap and try again
> > until you do manage to allocate the user resource.
>=20
> I meant removing the probe itself
> https://lkml.org/lkml/2011/4/21/279
>=20
> We could try reseting and retrying the trap. Just that we might end up
> looping under memory pressure.
>=20
> >=20
> > This behaviour makes probes totally unreliable under memory pressure.=
=20
>=20
> Under memory pressure we could be unreliable.=20

But that is total crap, there's nothing worse than unreliable debug
tools.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
