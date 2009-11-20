Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C37776B00B1
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 05:31:40 -0500 (EST)
Message-ID: <4B067007.8070607@cs.helsinki.fi>
Date: Fri, 20 Nov 2009 12:31:35 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
References: <4B064AF5.9060208@cn.fujitsu.com> <20091120081440.GA19778@elte.hu> <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com> <20091120083053.GB19778@elte.hu> <4B0657A4.2040606@cs.helsinki.fi> <20091120090134.GD19778@elte.hu> <84144f020911200115g14cfa3b5k959f8751001b8b35@mail.gmail.com> <20091120101305.GA16781@elte.hu>
In-Reply-To: <20091120101305.GA16781@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar kirjoitti:
> * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> 
>> Hi Ingo,
>>
>> On Fri, Nov 20, 2009 at 11:01 AM, Ingo Molnar <mingo@elte.hu> wrote:
>>> But ... even without that, perf is really fast and is supposed to build
>>> fine even in minimal (embedded) environments, so you can run it on the
>>> embedded board too. That's useful to get live inspection features like
>>> 'perf top', 'perf stat' and 'perf probe' anyway.
>> Maybe I'm just too damn lazy but if I don't go through the trouble of
>> building my kernel on the box, I sure don't want to do that for perf
>> either. [...]
> 
> Well you'll need 'perf' on that box anyway, to be able to do 'perf kmem 
> record'.

/me turns brains on

You're right, of course. With kmemtrace-user, I just copied the raw 
trace file from /sys/kernel. I wonder if that's a good enough reason to 
keep kmemtrace bits around?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
