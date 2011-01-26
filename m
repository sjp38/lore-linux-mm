Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C199D6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:29:10 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 14/20] 14: uprobes: Handing int3
 and singlestep exception.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110126151418.GL19725@linux.vnet.ibm.com>
References: 
	 <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
	 <20101216095957.23751.57040.sendpatchset@localhost6.localdomain6>
	 <1295963779.28776.1059.camel@laptop>
	 <20110126085203.GG19725@linux.vnet.ibm.com>
	 <1296037031.28776.1146.camel@laptop>
	 <20110126151418.GL19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 26 Jan 2011 16:29:48 +0100
Message-ID: <1296055788.28776.1222.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2011-01-26 at 20:44 +0530, Srikar Dronamraju wrote:
> So it simplifies to=20
>=20
>         down_read(&mm->mmap_sem);
>         vma =3D find_vma(mm, probept);
>         if (valid_vma(vma)) {
>                u =3D find_uprobe(vma->vm_file->f_mapping->host,
>                                probept - vma->vm_start);
>         }
>         up_read(&mm->mmap_sem);=20

Almost, the offset within a file is something like:

  (address - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
