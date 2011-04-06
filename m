Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA2338D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 19:46:36 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p36NKoWe030054
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 19:20:50 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2478938C803F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 19:46:24 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p36NkUHd325978
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 19:46:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p36NkTVQ007335
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 19:46:30 -0400
Date: Thu, 7 Apr 2011 05:16:24 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 22/26] 22: perf: rename target_module
 to target
Message-ID: <20110406234213.GC5806@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143657.15455.4701.sendpatchset@localhost6.localdomain6>
 <4D99980E.5080807@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4D99980E.5080807@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "2nddept-manager@sdl.hitachi.co.jp" <2nddept-manager@sdl.hitachi.co.jp>

> >  
> > -int show_available_funcs(const char *module, struct strfilter *_filter)
> > +int show_available_funcs(const char *elfobject, struct strfilter *_filter)
> >  {
> >  	struct map *map;
> >  	int ret;
> > @@ -1990,9 +1990,9 @@ int show_available_funcs(const char *module, struct strfilter *_filter)
> >  	if (ret < 0)
> >  		return ret;
> >  
> > -	map = kernel_get_module_map(module);
> > +	map = kernel_get_module_map(elfobject);
> >  	if (!map) {
> > -		pr_err("Failed to find %s map.\n", (module) ? : "kernel");
> > +		pr_err("Failed to find %s map.\n", (elfobject) ? : "kernel");
> 
> Hmm, these changes(module -> elfobject) are put back by the next patch.
> Could you check your patch stack?
> 

In the next patch, we move "map =
kernel_get_module_map(module/elfobject)" to a new function
available_kernel_funcs(). For example: Even after the next patch,
show_available_funcs() still takes elfobject and not module. If you want
to avoid this, then we would have to either introduce the
available_kernel_funcs() in this patch Or we could merge this and the
next patch. Both those solutions dont look clean to me.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
