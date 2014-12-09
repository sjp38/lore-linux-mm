Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF7A6B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 04:02:24 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so80717qcz.19
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:02:23 -0800 (PST)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com. [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id f19si590287qgd.35.2014.12.09.01.02.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 01:02:22 -0800 (PST)
Received: by mail-qa0-f53.google.com with SMTP id bm13so75872qab.26
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:02:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141208130344.9dc58fda1862a4a4a14c7c6b@linux-foundation.org>
References: <201412090206.Nd6JUQcF%fengguang.wu@intel.com> <20141208130344.9dc58fda1862a4a4a14c7c6b@linux-foundation.org>
From: David Drysdale <drysdale@google.com>
Date: Tue, 9 Dec 2014 09:02:02 +0000
Message-ID: <CAHse=S-7g77Dv+j7mUXgmAACs4czLQSv0VA361t=hecwQr03rg@mail.gmail.com>
Subject: Re: [next:master 10653/11539] arch/x86/ia32/audit.c:38:14: sparse:
 incompatible types for 'case' statement
Content-Type: multipart/alternative; boundary=089e015375b411c46a0509c4cde2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

--089e015375b411c46a0509c4cde2
Content-Type: text/plain; charset=UTF-8

On Mon, Dec 8, 2014 at 9:03 PM, Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Tue, 9 Dec 2014 02:40:09 +0800 kbuild test robot <
> fengguang.wu@intel.com> wrote:
>
> > tree:   git://
> git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   cf12164be498180dc466ef97194ca7755ea39f3b
> > commit: b4baa9e36be0651f7eb15077af5e0eff53b7691b [10653/11539] x86: hook
> up execveat system call
> > reproduce:
> >   # apt-get install sparse
> >   git checkout b4baa9e36be0651f7eb15077af5e0eff53b7691b
> >   make ARCH=x86_64 allmodconfig
> >   make C=1 CF=-D__CHECK_ENDIAN__
> >
> >
> > sparse warnings: (new ones prefixed by >>)
> >
> >    arch/x86/ia32/audit.c:38:14: sparse: undefined identifier
> '__NR_execveat'
> > >> arch/x86/ia32/audit.c:38:14: sparse: incompatible types for 'case'
> statement
> >    arch/x86/ia32/audit.c:38:14: sparse: Expected constant expression in
> case statement
> >    arch/x86/ia32/audit.c: In function 'ia32_classify_syscall':
> >    arch/x86/ia32/audit.c:38:7: error: '__NR_execveat' undeclared (first
> use in this function)
> >      case __NR_execveat:
> >           ^
> >    arch/x86/ia32/audit.c:38:7: note: each undeclared identifier is
> reported only once for each function it appears in
> > --
>
> Confused. This makes no sense and I can't reproduce it.
>

Ditto.

Someone else did previously[1] have a build problem from a stale copy of
arch/x86/include/generated/asm/unistd_32.h in their tree, but I don't know
how that could happen.

[1] https://lkml.org/lkml/2014/11/25/542

--089e015375b411c46a0509c4cde2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On M=
on, Dec 8, 2014 at 9:03 PM, Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"=
mailto:akpm@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.o=
rg</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"marg=
in:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,20=
4);border-left-style:solid;padding-left:1ex"><span>On Tue, 9 Dec 2014 02:40=
:09 +0800 kbuild test robot &lt;<a href=3D"mailto:fengguang.wu@intel.com" t=
arget=3D"_blank">fengguang.wu@intel.com</a>&gt; wrote:<br>
<br>
&gt; tree:=C2=A0 =C2=A0git://<a href=3D"http://git.kernel.org/pub/scm/linux=
/kernel/git/next/linux-next.git" target=3D"_blank">git.kernel.org/pub/scm/l=
inux/kernel/git/next/linux-next.git</a> master<br>
&gt; head:=C2=A0 =C2=A0cf12164be498180dc466ef97194ca7755ea39f3b<br>
&gt; commit: b4baa9e36be0651f7eb15077af5e0eff53b7691b [10653/11539] x86: ho=
ok up execveat system call<br>
&gt; reproduce:<br>
&gt;=C2=A0 =C2=A0# apt-get install sparse<br>
&gt;=C2=A0 =C2=A0git checkout b4baa9e36be0651f7eb15077af5e0eff53b7691b<br>
&gt;=C2=A0 =C2=A0make ARCH=3Dx86_64 allmodconfig<br>
&gt;=C2=A0 =C2=A0make C=3D1 CF=3D-D__CHECK_ENDIAN__<br>
&gt;<br>
&gt;<br>
&gt; sparse warnings: (new ones prefixed by &gt;&gt;)<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 arch/x86/ia32/audit.c:38:14: sparse: undefined identifier=
 &#39;__NR_execveat&#39;<br>
&gt; &gt;&gt; arch/x86/ia32/audit.c:38:14: sparse: incompatible types for &=
#39;case&#39; statement<br>
&gt;=C2=A0 =C2=A0 arch/x86/ia32/audit.c:38:14: sparse: Expected constant ex=
pression in case statement<br>
&gt;=C2=A0 =C2=A0 arch/x86/ia32/audit.c: In function &#39;ia32_classify_sys=
call&#39;:<br>
&gt;=C2=A0 =C2=A0 arch/x86/ia32/audit.c:38:7: error: &#39;__NR_execveat&#39=
; undeclared (first use in this function)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 case __NR_execveat:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0^<br>
&gt;=C2=A0 =C2=A0 arch/x86/ia32/audit.c:38:7: note: each undeclared identif=
ier is reported only once for each function it appears in<br>
&gt; --<br>
<br>
</span>Confused. This makes no sense and I can&#39;t reproduce it.<br>
</blockquote></div><br></div><div class=3D"gmail_extra">Ditto.</div><div cl=
ass=3D"gmail_extra"><br></div><div class=3D"gmail_extra">Someone else did p=
reviously[1] have a build problem from a stale copy of</div><div class=3D"g=
mail_extra"><span style=3D"font-size:13px">arch/x86/include/generated/</spa=
n><span style=3D"font-size:13px">asm/unistd_32.h in their tree, but I don&#=
39;t know</span></div><div class=3D"gmail_extra"><span style=3D"font-size:1=
3px">how that=C2=A0</span><span style=3D"font-size:13px">could happen.</spa=
n></div><div class=3D"gmail_extra"><span style=3D"font-size:13px"><br></spa=
n></div><div class=3D"gmail_extra"><span style=3D"font-size:13px">[1]=C2=A0=
</span><a href=3D"https://lkml.org/lkml/2014/11/25/542">https://lkml.org/lk=
ml/2014/11/25/542</a></div></div>

--089e015375b411c46a0509c4cde2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
