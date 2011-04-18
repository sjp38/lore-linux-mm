Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C492F900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:22:28 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 9/26]  9: uprobes: mmap and fork
 hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110401143413.15455.75831.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143413.15455.75831.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Apr 2011 18:21:57 +0200
Message-ID: <1303143717.32491.872.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-04-01 at 20:04 +0530, Srikar Dronamraju wrote:
> +       if (vma) {
> +               /*
> +                * We get here from uprobe_mmap() -- the case where we
> +                * are trying to copy an instruction from a page that's
> +                * not yet in page cache.
> +                *
> +                * Read page in before copy.
> +                */
> +               struct file *filp =3D vma->vm_file;
> +
> +               if (!filp)
> +                       return -EINVAL;
> +               page_cache_sync_readahead(mapping, &filp->f_ra, filp, idx=
, 1);
> +       }
> +       page =3D grab_cache_page(mapping, idx);=20

So I don't see why that isn't so for the normal install_uprobe() <-
register_uprobe() path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
