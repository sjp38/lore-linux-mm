Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C3D9E6B00DE
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 13:10:36 -0500 (EST)
Message-ID: <1322071812.14799.87.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 23 Nov 2011 19:10:12 +0100
In-Reply-To: <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> +                       ret =3D install_breakpoint(vma->vm_mm, uprobe);
> +                       if (ret =3D=3D -EEXIST) {
> +                               atomic_inc(&vma->vm_mm->mm_uprobes_count)=
;
> +                               ret =3D 0;
> +                       }=20

Aren't you double counting that probe position here? The one that raced
you to inserting it will also have incremented that counter, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
