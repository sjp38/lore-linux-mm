Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 428616B0044
	for <linux-mm@kvack.org>; Wed,  9 May 2012 18:24:28 -0400 (EDT)
Received: by dakp5 with SMTP id p5so1197140dak.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 15:24:27 -0700 (PDT)
Date: Wed, 9 May 2012 15:24:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: object allocation benchmark
In-Reply-To: <CAOJsxLEFsT3Ef9ztPnooJF2uSwELpkf90u_1=CtbvGGbO2LOiw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205091523040.5041@chino.kir.corp.google.com>
References: <4F6743C2.3090906@parallels.com> <alpine.DEB.2.00.1203191028160.19189@router.home> <alpine.DEB.2.00.1203191339470.27517@chino.kir.corp.google.com> <CAOJsxLEFsT3Ef9ztPnooJF2uSwELpkf90u_1=CtbvGGbO2LOiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-257374597-1336602266=:5041"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-257374597-1336602266=:5041
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 9 May 2012, Pekka Enberg wrote:

> >> I have some in kernel benchmarking tools for page allocator and slab
> >> allocators. But they are not really clean patches.
> >>
> >
> > This is the latest version of your tools that I have based on 3.3.  Load
> > the modules with insmod and it will produce an error to automatically
> > unloaded (by design) and check dmesg for the results.
> 
> Anyone interested in pushing the benchmark to mainline?
> 

It's a pretty atypical type of a benchmark that must be compiled and 
loaded as a benchmark for the most accurate results, I'm not sure if we 
want to carry it in the kernel or not.  I got these from when Christoph 
initially sent them for your tree.  If there's a renewed interest, let me 
know and I'll send you the ported changes (pagealloc_test.c, slab_test.c, 
and vmstat_test.c).
--397155492-257374597-1336602266=:5041--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
