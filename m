Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CBDFA6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:51:46 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l66so23969131wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:51:46 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id g65si4028230wma.77.2016.01.28.04.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 04:51:45 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id 128so9195887wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:51:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160128074051.GA15426@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
	<a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
	<20160128074051.GA15426@js1304-P5Q-DELUXE>
Date: Thu, 28 Jan 2016 13:51:45 +0100
Message-ID: <CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: multipart/alternative; boundary=089e012281428e534e052a646167
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, dvyukov@google.com, ryabinin.a.a@gmail.com, linux-mm@kvack.org, adech.fo@gmail.com, akpm@linux-foundation.org, rostedt@goodmis.org

--089e012281428e534e052a646167
Content-Type: text/plain; charset=UTF-8

On Jan 28, 2016 8:40 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>
> Hello,
>
> On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:
> > Stack depot will allow KASAN store allocation/deallocation stack traces
> > for memory chunks. The stack traces are stored in a hash table and
> > referenced by handles which reside in the kasan_alloc_meta and
> > kasan_free_meta structures in the allocated memory chunks.
>
> Looks really nice!
>
> Could it be more generalized to be used by other feature that need to
> store stack trace such as tracepoint or page owner?
Certainly yes, but see below.

> If it could be, there is one more requirement.
> I understand the fact that entry is never removed from depot makes things
> very simpler, but, for general usecases, it's better to use reference
count
> and allow to remove. Is it possible?
For our use case reference counting is not really necessary, and it would
introduce unwanted contention.
There are two possible options, each having its advantages and drawbacks:
we can let the clients store the refcounters directly in their stacks (more
universal, but harder to use for the clients), or keep the counters in the
depot but add an API that does not change them (easier for the clients, but
potentially error-prone).

I'd say it's better to actually find at least one more user for the stack
depot in order to understand the requirements, and refactor the code after
that.
> Thanks.
>

--089e012281428e534e052a646167
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jan 28, 2016 8:40 AM, &quot;Joonsoo Kim&quot; &lt;<a href=3D"mailto:iamj=
oonsoo.kim@lge.com">iamjoonsoo.kim@lge.com</a>&gt; wrote:<br>
&gt;<br>
&gt; Hello,<br>
&gt;<br>
&gt; On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:<b=
r>
&gt; &gt; Stack depot will allow KASAN store allocation/deallocation stack =
traces<br>
&gt; &gt; for memory chunks. The stack traces are stored in a hash table an=
d<br>
&gt; &gt; referenced by handles which reside in the kasan_alloc_meta and<br=
>
&gt; &gt; kasan_free_meta structures in the allocated memory chunks.<br>
&gt;<br>
&gt; Looks really nice!<br>
&gt;<br>
&gt; Could it be more generalized to be used by other feature that need to<=
br>
&gt; store stack trace such as tracepoint or page owner?<br>
Certainly yes, but see below.</p>
<p dir=3D"ltr">&gt; If it could be, there is one more requirement.<br>
&gt; I understand the fact that entry is never removed from depot makes thi=
ngs<br>
&gt; very simpler, but, for general usecases, it&#39;s better to use refere=
nce count<br>
&gt; and allow to remove. Is it possible?<br>
For our use case reference counting is not really necessary, and it would i=
ntroduce unwanted contention.<br>
There are two possible options, each having its advantages and drawbacks: w=
e can let the clients store the refcounters directly in their stacks (more =
universal, but harder to use for the clients), or keep the counters in the =
depot but add an API that does not change them (easier for the clients, but=
 potentially error-prone).</p>
<p dir=3D"ltr">I&#39;d say it&#39;s better to actually find at least one mo=
re user for the stack depot in order to understand the requirements, and re=
factor the code after that.<br>
&gt; Thanks.<br>
&gt;<br>
</p>

--089e012281428e534e052a646167--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
