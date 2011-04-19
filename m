Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0928D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 07:35:13 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 12/26] 12: uprobes: slot allocation
 for uprobes
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110419062654.GB10698@linux.vnet.ibm.com>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143457.15455.64839.sendpatchset@localhost6.localdomain6>
	 <1303145171.32491.886.camel@twins>
	 <20110419062654.GB10698@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 19 Apr 2011 11:02:26 +0200
Message-ID: <1303203746.32491.913.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: James Morris <jmorris@namei.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-04-19 at 11:56 +0530, Srikar Dronamraju wrote:
> > > +   /*
> > > +    * Find the end of the top mapping and skip a page.
> > > +    * If there is no space for PAGE_SIZE above
> > > +    * that, mmap will ignore our address hint.
> > > +    *
> > > +    * We allocate a "fake" unlinked shmem file because
> > > +    * anonymous memory might not be granted execute
> > > +    * permission when the selinux security hooks have
> > > +    * their way.
> > > +    */
> >=20
> > That just annoys me, so we're working around some stupid sekurity crap,
> > executable anonymous maps are perfectly fine, also what do JITs do?
>=20
> Yes, we are working around selinux security hooks, but do we have a
> choice.=20

Of course you have a choice, mark selinux broken and let them sort
it ;-)

Anyway, it looks like install_special_mapping() the thing I think you
ought to use (and I'm sure I said that before) also wobbles around
selinux by using security_file_mmap() even though its very clearly not a
file mmap (hint: vm_file =3D=3D NULL).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
