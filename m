Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 444B99000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:44:52 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 17/26]   x86: arch specific hooks for
 pre/post singlestep handling.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 13:44:12 +0200
In-Reply-To: <20110926163426.GA15435@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120325.25326.11641.sendpatchset@srdronam.in.ibm.com>
	 <1317047033.1763.27.camel@twins>
	 <20110926163426.GA15435@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317123853.15383.41.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2011-09-26 at 22:04 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-09-26 16:23:53]:
>=20
> > On Tue, 2011-09-20 at 17:33 +0530, Srikar Dronamraju wrote:
> > > +fail:
> > > +       pr_warn_once("uprobes: Failed to adjust return address after"
> > > +               " single-stepping call instruction;"
> > > +               " pid=3D%d, sp=3D%#lx\n", current->pid, sp);
> > > +       return -EFAULT;=20
> >=20
> > So how can that happen? Single-Step while someone unmapped the stack?
>=20
> We do a copy_to_user, copy_from_user just above this,

I saw that,

>  Now if either of
> them fail, we have no choice but to Bail out.

Agreed,

>  What caused this EFault may not be under Uprobes's Control.

I never said it was.. All I asked is what (outside of uprobe) was done
to cause this, and why is this particular error important enough to
warrant a warn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
