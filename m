Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5A3916B008A
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:25:15 -0500 (EST)
Message-ID: <4B065241.5040901@cn.fujitsu.com>
Date: Fri, 20 Nov 2009 16:24:33 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] tracing: Remove kmemtrace tracer
References: <4B064AF5.9060208@cn.fujitsu.com> <4B064B0B.30207@cn.fujitsu.com> <4B065145.2000709@cs.helsinki.fi>
In-Reply-To: <4B065145.2000709@cs.helsinki.fi>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

=E4=BA=8E 2009=E5=B9=B411=E6=9C=8820=E6=97=A5 16:20, Pekka Enberg =E5=86=99=
=E9=81=93:
> Li Zefan kirjoitti:
>> The kmem trace events can replace the functions of kmemtrace
>> tracer.
>>
>> And kmemtrace-user can be modified to use trace events.
>> (But after cloning the git repo, I found it's still based on
>> the original relay version..), not to mention now we have
>> 'perf kmem' tool.
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
>=20
> NAK for the time being. "perf kmem" output is not yet as good as that o=
f
> kmemtrace-user.
>=20

But is the current kmemtrace-user based on kmemtrace?

>From the git repo:
	http://repo.or.cz/w/kmemtrace-user.git

I found it's still based on relay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
