Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7D328D003B
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:40:37 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110127102527.GT19725@linux.vnet.ibm.com>
References: 
	 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
	 <1295957744.28776.722.camel@laptop>
	 <20110126075558.GB19725@linux.vnet.ibm.com>
	 <1296036708.28776.1138.camel@laptop>
	 <20110126153036.GN19725@linux.vnet.ibm.com>
	 <1296056756.28776.1247.camel@laptop>
	 <20110126165645.GP19725@linux.vnet.ibm.com>
	 <1296061949.28776.1343.camel@laptop>
	 <20110127100157.GS19725@linux.vnet.ibm.com>
	 <1296123817.15234.57.camel@laptop>
	 <20110127102527.GT19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 27 Jan 2011 11:41:17 +0100
Message-ID: <1296124877.15234.76.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-27 at 15:55 +0530, Srikar Dronamraju wrote:
>=20
>=20
> If its not at the exact same location, then our third validation of
> checking that (vaddr =3D=3D vma->vm_start + uprobe->offset)  should fail
> right?
>=20
> Also should it be (vaddr =3D=3D uprobe->offset + vma->vm_start -
> vma->pgoff << PAGE_SHIFT) ?

Yeah, although I just realized that ->offset should be a u64, since
pgoff is a unsigned long, we can have files up to 44 bit (assuming the
page-size is 12bits).

But yes, this matches the validation I mentioned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
