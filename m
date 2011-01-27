Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CD1498D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:23:01 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110127100157.GS19725@linux.vnet.ibm.com>
References: 
	 <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
	 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
	 <1295957744.28776.722.camel@laptop>
	 <20110126075558.GB19725@linux.vnet.ibm.com>
	 <1296036708.28776.1138.camel@laptop>
	 <20110126153036.GN19725@linux.vnet.ibm.com>
	 <1296056756.28776.1247.camel@laptop>
	 <20110126165645.GP19725@linux.vnet.ibm.com>
	 <1296061949.28776.1343.camel@laptop>
	 <20110127100157.GS19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 27 Jan 2011 11:23:37 +0100
Message-ID: <1296123817.15234.57.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-27 at 15:31 +0530, Srikar Dronamraju wrote:
> > > >  - validate that the vma is indeed a map of the right inode
> > >=20
> > > We can add a check in write_opcode( we need to pass the inode to
> > > write_opcode).
> >=20
> > sure..
> >=20
> > > >  - validate that the offset of the probe corresponds with the store=
d
> > > > address
> > >=20
> > > I am not clear on this. We would have derived the address from the
> > > offset. So is that we check for
> > >  (vaddr =3D=3D vma->vm_start + uprobe->offset)
> >=20
> > Sure, but the vma might have changed since you computed the offset -)
>=20
> If the vma has changed then it would fail the 2nd validation i.e vma
> corresponds to the uprobe inode right. If the vma was unmapped and
> mapped back at the same place, then I guess we are okay to probe.

It can be unmapped and mapped back slightly different. A map of the same
file doesn't need to mean its in the exact same location or has the
exact same pgoffset.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
