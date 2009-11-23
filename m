Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E781D6B007E
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:46:27 -0500 (EST)
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <20091120104920.GA12634@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
	 <20091120081440.GA19778@elte.hu>
	 <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
	 <20091120083053.GB19778@elte.hu> <4B0657A4.2040606@cs.helsinki.fi>
	 <20091120090134.GD19778@elte.hu>
	 <84144f020911200115g14cfa3b5k959f8751001b8b35@mail.gmail.com>
	 <20091120101305.GA16781@elte.hu> <4B067007.8070607@cs.helsinki.fi>
	 <20091120104920.GA12634@elte.hu>
Content-Type: text/plain
Date: Mon, 23 Nov 2009 09:46:25 -0500
Message-Id: <1258987585.22249.1036.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Li Zefan <lizf@cn.fujitsu.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-11-20 at 11:49 +0100, Ingo Molnar wrote:
> > 
> > You're right, of course. With kmemtrace-user, I just copied the raw 
> > trace file from /sys/kernel. I wonder if that's a good enough reason 
> > to keep kmemtrace bits around?
> 
> Not really. If then a light-weight recording app could be made but i'd 
> rather wait for actual usecases to pop up.

Hmm, but isn't this an actual use case?

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
