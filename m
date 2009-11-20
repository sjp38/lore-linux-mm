Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7E58C6B00AA
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 04:15:25 -0500 (EST)
Received: by fxm25 with SMTP id 25so3649442fxm.6
        for <linux-mm@kvack.org>; Fri, 20 Nov 2009 01:15:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091120090134.GD19778@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com> <20091120081440.GA19778@elte.hu>
	 <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
	 <20091120083053.GB19778@elte.hu> <4B0657A4.2040606@cs.helsinki.fi>
	 <20091120090134.GD19778@elte.hu>
Date: Fri, 20 Nov 2009 11:15:23 +0200
Message-ID: <84144f020911200115g14cfa3b5k959f8751001b8b35@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Fri, Nov 20, 2009 at 11:01 AM, Ingo Molnar <mingo@elte.hu> wrote:
> But ... even without that, perf is really fast and is supposed to build
> fine even in minimal (embedded) environments, so you can run it on the
> embedded board too. That's useful to get live inspection features like
> 'perf top', 'perf stat' and 'perf probe' anyway.

Maybe I'm just too damn lazy but if I don't go through the trouble of
building my kernel on the box, I sure don't want to do that for perf
either. Anyway, I'm sure we can fix "perf kmem" to support what
kmemtrace-user does so it's not an issue.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
