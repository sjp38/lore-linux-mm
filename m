Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 41D056B00A4
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 01:12:43 -0500 (EST)
Message-ID: <4B21E29E.2030507@cn.fujitsu.com>
Date: Fri, 11 Dec 2009 14:11:42 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] tracing: Define kmem_trace_alloc_notrace unconditionally
References: <4B21DD88.7080806@cn.fujitsu.com> <4B21DF33.7010906@cs.helsinki.fi> <4B21E028.3030107@cs.helsinki.fi>
In-Reply-To: <4B21E028.3030107@cs.helsinki.fi>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

=E4=BA=8E 2009=E5=B9=B412=E6=9C=8811=E6=97=A5 14:01, Pekka Enberg =E5=86=99=
=E9=81=93:
> Pekka Enberg wrote:
>> Li Zefan wrote:
>>> Always define kmem_trace_alloc_{,node}_notrace(), otherwise
>>> perf-kmem will show wrong stats ifndef CONFIG_KMEMTRACE,
>>> because a kmalloc() memory allocation may be traced by
>>> both trace_kmalloc() and trace_kmem_cache_alloc().
>>>
>>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
>>
>> Did you check how much this will make kernel text bigger because of
>> the inlining happening in kmem_cache_alloc_notrace()?
>=20
> Maybe use CONFIG_TRACING instead of CONFIG_KMEMTRACE here like in the
> other patch?
>=20

Wouldn't removing CONFIG_KMEMTRACE make the code cleaner?
Anyway, if CONFIG_TRACING is not enabled, all the trace_xxx()
will be turned into no-op.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
