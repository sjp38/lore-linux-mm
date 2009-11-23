Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 107426B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 02:28:56 -0500 (EST)
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091123065110.GC31758@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
	 <20091120081440.GA19778@elte.hu>
	 <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
	 <20091120083053.GB19778@elte.hu> <4B0657A4.2040606@cs.helsinki.fi>
	 <4B06590C.7010109@cn.fujitsu.com> <20091120090353.GE19778@elte.hu>
	 <20091120144215.GH18283@ghostprotocols.net>
	 <20091120164110.GA24183@elte.hu>
	 <20091120175228.GD27926@ghostprotocols.net>
	 <20091123065110.GC31758@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 Nov 2009 08:22:21 +0100
Message-ID: <1258960941.4531.19.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-23 at 07:51 +0100, Ingo Molnar wrote:
> 
> * Arnaldo Carvalho de Melo <acme@infradead.org> wrote:
> 
> > Em Fri, Nov 20, 2009 at 05:41:10PM +0100, Ingo Molnar escreveu:
> > > > So we have a mechanism that is already present in several distros
> > > > (build-id), that is in the kernel build process since ~2.6.23, and that
> > > > avoids using mismatching DSOs when resolving symbols.
> > > 
> > > But what do we do if we have another box that runs say on a MIPS CPU, 
> > > uses some minimal distro - and copy that perf.data over to an x86 box.
> > 
> > There would be no problem, it would be just a matter of installing the
> > right -debuginfo packages, for MIPS.
> 
> I havent tried this - is this really possible to do on an x86 box, with 
> a typical distro? Can i install say Fedora PowerPC debuginfo packages on 
> an x86 box, while also having the x86 debuginfo packages there? 

The best option would be to allow to specify a chroot parameter, where
we can specify the embedded root filesystem on out machine.

I'm not even sure embedded distros even have this separate debug package
crazyness, you simply build the distro with or without debuginfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
