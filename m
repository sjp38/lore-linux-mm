Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B598D6B006A
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 02:33:29 -0500 (EST)
Date: Mon, 23 Nov 2009 08:33:17 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
Message-ID: <20091123073317.GA16628@elte.hu>
References: <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
 <20091120083053.GB19778@elte.hu>
 <4B0657A4.2040606@cs.helsinki.fi>
 <4B06590C.7010109@cn.fujitsu.com>
 <20091120090353.GE19778@elte.hu>
 <20091120144215.GH18283@ghostprotocols.net>
 <20091120164110.GA24183@elte.hu>
 <20091120175228.GD27926@ghostprotocols.net>
 <20091123065110.GC31758@elte.hu>
 <1258960941.4531.19.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1258960941.4531.19.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> > I havent tried this - is this really possible to do on an x86 box, 
> > with a typical distro? Can i install say Fedora PowerPC debuginfo 
> > packages on an x86 box, while also having the x86 debuginfo packages 
> > there?
> 
> The best option would be to allow to specify a chroot parameter, where 
> we can specify the embedded root filesystem on out machine.
> 
> I'm not even sure embedded distros even have this separate debug 
> package crazyness, you simply build the distro with or without 
> debuginfo.

yes - we could use -R/--root (which opreport has as well), as a 
mandatory path prefix to all DSO/debuginfo searches.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
