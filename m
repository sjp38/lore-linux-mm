Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4E8106B0099
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:32:11 -0500 (EST)
Message-ID: <4B0653E0.5090407@cn.fujitsu.com>
Date: Fri, 20 Nov 2009 16:31:28 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] tracing: Remove kmemtrace tracer
References: <4B064AF5.9060208@cn.fujitsu.com> <4B064B0B.30207@cn.fujitsu.com>	 <4B065145.2000709@cs.helsinki.fi> <4B065241.5040901@cn.fujitsu.com> <84144f020911200027m6ac15e48laf95f7f3f8a92e3d@mail.gmail.com>
In-Reply-To: <84144f020911200027m6ac15e48laf95f7f3f8a92e3d@mail.gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> On Fri, Nov 20, 2009 at 10:24 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>> =D3=DA 2009=C4=EA11=D4=C220=C8=D5 16:20, Pekka Enberg =D0=B4=B5=C0:
>>> Li Zefan kirjoitti:
>>>> The kmem trace events can replace the functions of kmemtrace
>>>> tracer.
>>>>
>>>> And kmemtrace-user can be modified to use trace events.
>>>> (But after cloning the git repo, I found it's still based on
>>>> the original relay version..), not to mention now we have
>>>> 'perf kmem' tool.
>>>>
>>>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
>>> NAK for the time being. "perf kmem" output is not yet as good as that=
 of
>>> kmemtrace-user.
>>>
>> But is the current kmemtrace-user based on kmemtrace?
>>
>> From the git repo:
>>        http://repo.or.cz/w/kmemtrace-user.git
>>
>> I found it's still based on relay.
>=20
> The "ftrace-temp" branch seems to have the ftrace based version in it. =
Eduard?
>=20

Thanks. I just overlooked the branch..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
