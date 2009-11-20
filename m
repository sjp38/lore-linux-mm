Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 163126B0093
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:27:18 -0500 (EST)
Received: by fxm25 with SMTP id 25so3605361fxm.6
        for <linux-mm@kvack.org>; Fri, 20 Nov 2009 00:27:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B065241.5040901@cn.fujitsu.com>
References: <4B064AF5.9060208@cn.fujitsu.com> <4B064B0B.30207@cn.fujitsu.com>
	 <4B065145.2000709@cs.helsinki.fi> <4B065241.5040901@cn.fujitsu.com>
Date: Fri, 20 Nov 2009 10:27:16 +0200
Message-ID: <84144f020911200027m6ac15e48laf95f7f3f8a92e3d@mail.gmail.com>
Subject: Re: [PATCH 2/2] tracing: Remove kmemtrace tracer
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 20, 2009 at 10:24 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> =D3=DA 2009=C4=EA11=D4=C220=C8=D5 16:20, Pekka Enberg =D0=B4=B5=C0:
>> Li Zefan kirjoitti:
>>> The kmem trace events can replace the functions of kmemtrace
>>> tracer.
>>>
>>> And kmemtrace-user can be modified to use trace events.
>>> (But after cloning the git repo, I found it's still based on
>>> the original relay version..), not to mention now we have
>>> 'perf kmem' tool.
>>>
>>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
>>
>> NAK for the time being. "perf kmem" output is not yet as good as that of
>> kmemtrace-user.
>>
>
> But is the current kmemtrace-user based on kmemtrace?
>
> From the git repo:
>        http://repo.or.cz/w/kmemtrace-user.git
>
> I found it's still based on relay.

The "ftrace-temp" branch seems to have the ftrace based version in it. Edua=
rd?

                      Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
