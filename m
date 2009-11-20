Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 219676B00A9
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 04:15:17 -0500 (EST)
Message-ID: <4B065DFB.8090909@cn.fujitsu.com>
Date: Fri, 20 Nov 2009 17:14:35 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
References: <4B064AF5.9060208@cn.fujitsu.com> <20091120081440.GA19778@elte.hu> <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com> <20091120083053.GB19778@elte.hu> <4B0657A4.2040606@cs.helsinki.fi> <4B06590C.7010109@cn.fujitsu.com> <20091120090353.GE19778@elte.hu>
In-Reply-To: <20091120090353.GE19778@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>>> (2) doing "perf kmem record" on machine A (think embedded here) and 
>>> then "perf kmem report" on machine B. I haven't tried kmemtrace-user 
>>> for a while but it did support both of them quite nicely at some 
>>> point.
>> Everything needed and machine-specific will be recorded in perf.data, 
>> so this should already been supported. I'll try it.
> 
> Right now the DSOs are not recorded in the perf.data - but it would be 
> useful to add it and to turn perf.data into a self-sufficient capture of 
> all relevant data, which can be analyzed on any box.
> 

But still 'perf kmem' should function better than kmemtrace-user,
since the latter records no more than raw trace data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
