Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 7A8036B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 07:28:54 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id q13so1454768lbi.23
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 04:28:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130410161144.GA25394@optiplex.redhat.com>
References: <CABA9-+oTDAOTFYbxeqkXGv1YN4eC-uj86hCihPbS8w-xpJCAxg@mail.gmail.com>
	<20130410161144.GA25394@optiplex.redhat.com>
Date: Thu, 11 Apr 2013 08:28:52 -0300
Message-ID: <CABA9-+ppvxUhCQrgH6FMaEGQyUajsksD-wMvBk8y+ANpBvLtew@mail.gmail.com>
Subject: Re: How much memory kernel uses
From: Ricardo Jose Pfitscher <ricardo.pfitscher@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b344172551c1604da1417dd
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org

--047d7b344172551c1604da1417dd
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Jerry,

Thanks for your answer.

I want to know how much memory the kernel is currently using --
text+data+heap+stack, if possible. I understand that heap and stack can be
gleaned by looking at Slab and KernelStack in /proc/meminfo, but I don't
know how can I account for the kernel code and other data.

In case you're wondering why the heck I want to know this, I'm trying to
estimate how much physical memory I actually need in a system, by comparing
memory usage to available memory. Subtracting buffers+cache from free
memory gives me how much memory is being used by user processes, without
accounting for memory used by the kernel.

Any rules (either hard and fast, or rules of thumb) on how much memory
should be free before the system "senses" memory pressure would also help.
My goal is to detect memory shortages (long) before the system starts
hitting swap space.

Best regards,
Ricardo


2013/4/10 Rafael Aquini <aquini@redhat.com>

> On Tue, Apr 09, 2013 at 10:07:37PM -0300, Ricardo Jose Pfitscher wrote:
> >    Hello guys,
> >    I need help with memory management, i have a question: Is there a wa=
y
> >    to find out how much memory is being used by the kernel (preferably
> >    form userspace)?
> >    Anything like /proc/meminfo....
> >    Thank you,
> >    --
> >    Ricardo Jos=E9 Pfitscher
>
> Take a glance at http://www.halobates.de/memorywaste.pdf as a start-point
> to
> understand where the kernel is potentially using memory (the doc is old,
> and
> things might have changed a bit since its publication, but it stills vali=
d
> as a
> study reference). Also, this userland tool might come handy to your
> studies:
> http://www.selenic.com/smem/
>
>
>


--=20
Ricardo Jos=E9 Pfitscher

--047d7b344172551c1604da1417dd
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span style=3D"font-family:arial,sans-serif;font-size:13px=
">Hi Jerry,=A0</span><div style=3D"font-family:arial,sans-serif;font-size:1=
3px"><br></div><div style=3D"font-family:arial,sans-serif;font-size:13px">T=
hanks for your answer.</div>
<div style=3D"font-family:arial,sans-serif;font-size:13px"><br></div><div s=
tyle=3D"font-family:arial,sans-serif;font-size:13px">I want to know how muc=
h memory the kernel is currently using -- text+data+heap+stack, if possible=
. I understand that heap and stack can be gleaned by looking at Slab and Ke=
rnelStack in /proc/meminfo, but I don&#39;t know how can I account for the =
kernel code and other data.=A0<div>
<br></div><div>In case you&#39;re wondering why the heck I want to know thi=
s, I&#39;m trying to estimate how much physical memory I actually need in a=
 system, by comparing memory usage to available memory. Subtracting buffers=
+cache from free memory gives me how much memory is being used by user proc=
esses, without accounting for memory used by the kernel.</div>
<div><br></div><div>Any rules (either hard and fast, or rules of thumb) on =
how much memory should be free before the system &quot;senses&quot; memory =
pressure would also help. My goal is to detect memory shortages (long) befo=
re the system starts hitting swap space.=A0</div>
<div><br></div><div>Best regards,</div><div>Ricardo</div></div></div><div c=
lass=3D"gmail_extra"><br><br><div class=3D"gmail_quote">2013/4/10 Rafael Aq=
uini <span dir=3D"ltr">&lt;<a href=3D"mailto:aquini@redhat.com" target=3D"_=
blank">aquini@redhat.com</a>&gt;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">On T=
ue, Apr 09, 2013 at 10:07:37PM -0300, Ricardo Jose Pfitscher wrote:<br>
&gt; =A0 =A0Hello guys,<br>
&gt; =A0 =A0I need help with memory management, i have a question: Is there=
 a way<br>
&gt; =A0 =A0to find out how much memory is being used by the kernel (prefer=
ably<br>
&gt; =A0 =A0form userspace)?<br>
&gt; =A0 =A0Anything like /proc/meminfo....<br>
&gt; =A0 =A0Thank you,<br>
&gt; =A0 =A0--<br>
&gt; =A0 =A0Ricardo Jos=E9 Pfitscher<br>
<br>
</div></div>Take a glance at <a href=3D"http://www.halobates.de/memorywaste=
.pdf" target=3D"_blank">http://www.halobates.de/memorywaste.pdf</a> as a st=
art-point to<br>
understand where the kernel is potentially using memory (the doc is old, an=
d<br>
things might have changed a bit since its publication, but it stills valid =
as a<br>
study reference). Also, this userland tool might come handy to your studies=
:<br>
<a href=3D"http://www.selenic.com/smem/" target=3D"_blank">http://www.selen=
ic.com/smem/</a><br>
<br>
<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>Ricardo Jos=
=E9 Pfitscher<br><br><div><br></div>
</div>

--047d7b344172551c1604da1417dd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
