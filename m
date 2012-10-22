Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 843B56B0073
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 16:56:01 -0400 (EDT)
Date: Mon, 22 Oct 2012 13:55:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch for-3.7 v3] mm, mempolicy: hold task->mempolicy refcount
 while reading numa_maps.
Message-Id: <20121022135559.1ccb14bc.akpm@linux-foundation.org>
In-Reply-To: <5084B3C3.3070906@jp.fujitsu.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
	<20121017040515.GA13505@redhat.com>
	<alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
	<20121017181413.GA16805@redhat.com>
	<alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com>
	<20121017193229.GC16805@redhat.com>
	<alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com>
	<20121017194501.GA24400@redhat.com>
	<alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com>
	<507F803A.8000900@jp.fujitsu.com>
	<507F86BD.7070201@jp.fujitsu.com>
	<alpine.DEB.2.00.1210181255470.26994@chino.kir.corp.google.com>
	<508110C4.6030805@jp.fujitsu.com>
	<alpine.DEB.2.00.1210190227240.26815@chino.kir.corp.google.com>
	<5084B3C3.3070906@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 22 Oct 2012 11:47:31 +0900
Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> (2012/10/19 18:28), David Rientjes wrote:
> 
> > Looks good, but the patch is whitespace damaged so it doesn't apply.  When
> > that's fixed:
> >
> > Acked-by: David Rientjes <rientjes@google.com>
> 
> Sorry, I hope this one is not broken...
>
> ...
>
> --- a/fs/proc/internal.h
> +++ b/fs/proc/internal.h
> @@ -12,6 +12,7 @@
>   #include <linux/sched.h>
>   #include <linux/proc_fs.h>
>   struct  ctl_table_header;
> +struct  mempolicy;
>   
>   extern struct proc_dir_entry proc_root;
>   #ifdef CONFIG_PROC_SYSCTL
> @@ -74,6 +75,9 @@ struct proc_maps_private {
>   #ifdef CONFIG_MMU
>   	struct vm_area_struct *tail_vma;
>   #endif
> +#ifdef CONFIG_NUMA
> +	struct mempolicy *task_mempolicy;
> +#endif
>   };

The mail client space-stuffed it.

We merged this three days ago, in 9e7814404b77c3e8920b.  Please check
that it landed OK - there's a newline fixup in there but it looks good
to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
