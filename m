Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BD9526B009D
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:54:14 -0500 (EST)
Message-ID: <4B06590C.7010109@cn.fujitsu.com>
Date: Fri, 20 Nov 2009 16:53:32 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
References: <4B064AF5.9060208@cn.fujitsu.com> <20091120081440.GA19778@elte.hu> <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com> <20091120083053.GB19778@elte.hu> <4B0657A4.2040606@cs.helsinki.fi>
In-Reply-To: <4B0657A4.2040606@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Ingo Molnar kirjoitti:
>> Regarding patch 2 - can we set some definitive benchmark threshold for
>> that? I.e. a list of must-have features in 'perf kmem' before we can
>> do it? 100% information and analysis equivalency with kmemtrace-user
>> tool? 
> 
> I'd be interested to hear Eduard's comment on that.
> 
> That said, I'll try to find some time to test "perf kmem" and provide
> feedback on that. I can ACK the patch when I'm happy with the output. :-)
> 
> I'm mostly interested in two scenarios: (1) getting a nice report on
> worst fragmented call-sites (perf kmem needs symbol lookup) and

This will be done in next version.

> (2) doing "perf kmem record" on machine A (think embedded here) and then
> "perf kmem report" on machine B. I haven't tried kmemtrace-user for a
> while but it did support both of them quite nicely at some point.
> 

Everything needed and machine-specific will be recorded in perf.data,
so this should already been supported. I'll try it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
