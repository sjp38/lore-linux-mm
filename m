Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CA0F16B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 07:57:00 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110719065350.GB1210@linux.vnet.ibm.com>
References: <20110617090504.GN4952@linux.vnet.ibm.com>
	 <1308303665.2355.11.camel@twins> <1308662243.26237.144.camel@twins>
	 <20110622143906.GF16471@linux.vnet.ibm.com>
	 <20110624020659.GA24776@linux.vnet.ibm.com>
	 <1308901324.27849.7.camel@twins>
	 <20110627064502.GB24776@linux.vnet.ibm.com> <1309165071.6701.4.camel@twins>
	 <20110718092055.GA1210@linux.vnet.ibm.com>
	 <1310999476.13765.107.camel@twins>
	 <20110719065350.GB1210@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Jul 2011 13:56:22 +0200
Message-ID: <1311162982.5345.47.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-07-19 at 12:23 +0530, Srikar Dronamraju wrote:
> > I don't think you can sell this, that'll make munmap() horridly slow.
>=20
> Okay,=20
>=20
> How about using a counter and a wq in each vma.
> Based on the counter, I can wait in the munmap() and since this is per
> vma, this should be faster than srcu.
>=20
> Counter would be incremented when we do a vma-rmap walk.=20
> decremented when after insertion/deletion.
> read in munmap().=20

I know I would feel somewhat uneasy about growing struct vm_area_struct
for just uprobes, but what do other people think?=20

Andrew, Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
