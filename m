Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 502A56B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:26:30 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so31680594wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 12:26:30 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id bv6si12947067wjc.97.2016.03.11.12.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 12:26:29 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id l68so31680258wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 12:26:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160311121923.656fbcc79b5490109573c65a@linux-foundation.org>
References: <201603111844.8T3LiLoa%fengguang.wu@intel.com>
	<20160311121923.656fbcc79b5490109573c65a@linux-foundation.org>
Date: Fri, 11 Mar 2016 21:26:28 +0100
Message-ID: <CAG_fn=WN0hT3DPSXGr3OD8uLRD5kXxbDgKY=zedOXvktfYwfVw@mail.gmail.com>
Subject: Re: [linux-next:master 11691/11963] mm/kasan/kasan.c:429:12: error:
 dereferencing pointer to incomplete type 'struct stack_trace'
From: Alexander Potapenko <glider@google.com>
Content-Type: multipart/alternative; boundary=047d7bfd0c06f47ce5052dcbbe7e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, kbuild test robot <fengguang.wu@intel.com>

--047d7bfd0c06f47ce5052dcbbe7e
Content-Type: text/plain; charset=UTF-8

On Mar 11, 2016 9:19 PM, "Andrew Morton" <akpm@linux-foundation.org> wrote:
>
> On Fri, 11 Mar 2016 18:38:47 +0800 kbuild test robot <
fengguang.wu@intel.com> wrote:
>
> > tree:
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   bb17bf337db5c5af7e75ec5916772c9bffcaf981
> > commit: d5e0cb037c3f7a9cc54b9427e0281c7877d62ff3 [11691/11963] mm,
kasan: stackdepot implementation. Enable stackdepot for SLAB
> > config: x86_64-randconfig-v0-03111742 (attached as .config)
> > reproduce:
> >         git checkout d5e0cb037c3f7a9cc54b9427e0281c7877d62ff3
> >         # save the attached .config to linux build tree
> >         make ARCH=x86_64
> >
> > All error/warnings (new ones prefixed by >>):
> >
> >    mm/kasan/kasan.c: In function 'filter_irq_stacks':
> > >> mm/kasan/kasan.c:429:12: error: dereferencing pointer to incomplete
type 'struct stack_trace'
> >      if (!trace->nr_entries)
>
> Yeah, that's a bit screwed up.  The code needs CONFIG_STACKTRACE but this:
>
> ---
a/lib/Kconfig.kasan~mm-kasan-stackdepot-implementation-enable-stackdepot-for-slab-fix-fix
> +++ a/lib/Kconfig.kasan
> @@ -8,6 +8,7 @@ config KASAN
>         depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
>         select CONSTRUCTORS
>         select STACKDEPOT if SLAB
> +       select STACKTRACE if SLAB
>         help
>           Enables kernel address sanitizer - runtime memory debugger,
>           designed to find out-of-bounds accesses and use-after-free bugs.
>
> doesn't work because CONFIG_SLAB=n.  And I don't think we want to
> enable all this extra stuff for slub/slob/etc.
>
> Over to you, Alexander.
Um, perhaps the code in question should be SLAB-only. I'll send the fix on
Monday.

--047d7bfd0c06f47ce5052dcbbe7e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Mar 11, 2016 9:19 PM, &quot;Andrew Morton&quot; &lt;<a href=3D"mailto:ak=
pm@linux-foundation.org">akpm@linux-foundation.org</a>&gt; wrote:<br>
&gt;<br>
&gt; On Fri, 11 Mar 2016 18:38:47 +0800 kbuild test robot &lt;<a href=3D"ma=
ilto:fengguang.wu@intel.com">fengguang.wu@intel.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; tree:=C2=A0 =C2=A0<a href=3D"https://git.kernel.org/pub/scm/linux=
/kernel/git/next/linux-next.git">https://git.kernel.org/pub/scm/linux/kerne=
l/git/next/linux-next.git</a> master<br>
&gt; &gt; head:=C2=A0 =C2=A0bb17bf337db5c5af7e75ec5916772c9bffcaf981<br>
&gt; &gt; commit: d5e0cb037c3f7a9cc54b9427e0281c7877d62ff3 [11691/11963] mm=
, kasan: stackdepot implementation. Enable stackdepot for SLAB<br>
&gt; &gt; config: x86_64-randconfig-v0-03111742 (attached as .config)<br>
&gt; &gt; reproduce:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0git checkout d5e0cb037c3f7a9cc54=
b9427e0281c7877d62ff3<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# save the attached .config to l=
inux build tree<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0make ARCH=3Dx86_64<br>
&gt; &gt;<br>
&gt; &gt; All error/warnings (new ones prefixed by &gt;&gt;):<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 mm/kasan/kasan.c: In function &#39;filter_irq_stacks=
&#39;:<br>
&gt; &gt; &gt;&gt; mm/kasan/kasan.c:429:12: error: dereferencing pointer to=
 incomplete type &#39;struct stack_trace&#39;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 if (!trace-&gt;nr_entries)<br>
&gt;<br>
&gt; Yeah, that&#39;s a bit screwed up.=C2=A0 The code needs CONFIG_STACKTR=
ACE but this:<br>
&gt;<br>
&gt; --- a/lib/Kconfig.kasan~mm-kasan-stackdepot-implementation-enable-stac=
kdepot-for-slab-fix-fix<br>
&gt; +++ a/lib/Kconfig.kasan<br>
&gt; @@ -8,6 +8,7 @@ config KASAN<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 depends on SLUB_DEBUG || (SLAB &amp;&amp; =
!DEBUG_SLAB)<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 select CONSTRUCTORS<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 select STACKDEPOT if SLAB<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0select STACKTRACE if SLAB<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 help<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Enables kernel address sanitizer - =
runtime memory debugger,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 designed to find out-of-bounds acce=
sses and use-after-free bugs.<br>
&gt;<br>
&gt; doesn&#39;t work because CONFIG_SLAB=3Dn.=C2=A0 And I don&#39;t think =
we want to<br>
&gt; enable all this extra stuff for slub/slob/etc.<br>
&gt;<br>
&gt; Over to you, Alexander.<br>
Um, perhaps the code in question should be SLAB-only. I&#39;ll send the fix=
 on Monday.<br>
</p>

--047d7bfd0c06f47ce5052dcbbe7e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
