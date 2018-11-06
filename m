Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A87AC6B0495
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 17:10:42 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id g12-v6so4385785lji.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 14:10:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m4-v6sor7989079lji.36.2018.11.06.14.10.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 14:10:40 -0800 (PST)
MIME-Version: 1.0
References: <bug-201603-27@https.bugzilla.kernel.org/> <20181106134837.014c0bf61eb959e27f5edd0c@linux-foundation.org>
In-Reply-To: <20181106134837.014c0bf61eb959e27f5edd0c@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 6 Nov 2018 23:10:28 +0100
Message-ID: <CAMJBoFOw1J3PYxTL7GBXmVW+tNBjdcGU+4FBh+vdf7aY0sv1ZA@mail.gmail.com>
Subject: Re: [Bug 201603] New: NULL pointer dereference when using z3fold and zswap
Content-Type: multipart/alternative; boundary="0000000000009cecf6057a064557"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>, jagannathante@gmail.com

--0000000000009cecf6057a064557
Content-Type: text/plain; charset="UTF-8"

Hi,
Den tis 6 nov. 2018 kl 22:48 skrev Andrew Morton <akpm@linux-foundation.org
>:

>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Fri, 02 Nov 2018 10:41:46 +0000 bugzilla-daemon@bugzilla.kernel.org
> wrote:
>
> > https://bugzilla.kernel.org/show_bug.cgi?id=201603
> >
> >             Bug ID: 201603
> >            Summary: NULL pointer dereference when using z3fold and zswap
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.18.16
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Page Allocator
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: jagannathante@gmail.com
> >         Regression: No
> >
> > Created attachment 279297
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=279297&action=edit
> > dmesg log of crash
>
>
Basing on what I see in dmesg, it is highly likely to get fixed by
https://lkml.org/lkml/2018/11/5/726. Could you please apply/retest?

Best regards,
   Vitaly

> > This happens mostly during memory pressure but I am not sure how to
> trigger it
> > reliably. I am attaching the full log.
> >
> > This is the kernel commandline
> >
> > >BOOT_IMAGE=../vmlinuz-linux
> root=UUID=57274b3a-92ab-468e-b03a-06026675c1af rw
> > >rd.luks.name=92b4aeb2-fb97-45c1-8a60-2816efe5d57e=home
> resume=/dev/mapper/home
> > >resume_offset=42772480 acpi_backlight=video zswap.enabled=1
> zswap.zpool=z3fold
> > >zswap.max_pool_percent=5 transparent_hugepage=madvise
> scsi_mod.use_blk_mq=1
> > >vga=current initrd=../intel-ucode.img,../initramfs-linux.img
> >
> > I found this bug https://bugzilla.kernel.org/show_bug.cgi?id=198585 to
> be very
> > similar but the proposed fix has not been merged so I can't be sure if
> it will
> > fix the issue I am having.
> >
> > --
> > You are receiving this mail because:
> > You are the assignee for the bug.
>

--0000000000009cecf6057a064557
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr">Hi,<br><div class=3D"gmail_quote"><div di=
r=3D"ltr">Den tis 6 nov. 2018 kl 22:48 skrev Andrew Morton &lt;<a href=3D"m=
ailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt;:<br></di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;borde=
r-left:1px solid rgb(204,204,204);padding-left:1ex"><br>
(switched to email.=C2=A0 Please respond via emailed reply-to-all, not via =
the<br>
bugzilla web interface).<br>
<br>
On Fri, 02 Nov 2018 10:41:46 +0000 <a href=3D"mailto:bugzilla-daemon@bugzil=
la.kernel.org" target=3D"_blank">bugzilla-daemon@bugzilla.kernel.org</a> wr=
ote:<br>
<br>
&gt; <a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D201603" rel=
=3D"noreferrer" target=3D"_blank">https://bugzilla.kernel.org/show_bug.cgi?=
id=3D201603</a><br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Bug ID: 201603<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Summary: NULL pointer derefer=
ence when using z3fold and zswap<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Product: Memory Management<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Version: 2.5<br>
&gt;=C2=A0 =C2=A0 =C2=A0Kernel Version: 4.18.16<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Hardware: All<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0OS: Linux=
<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Tree: Mainline<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Status: NEW<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Severity: high<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Priority: P1<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Component: Page Allocator<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Assignee: <a href=3D"mailto:ak=
pm@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a><br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Reporter: <a href=3D"mailto:ja=
gannathante@gmail.com" target=3D"_blank">jagannathante@gmail.com</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Regression: No<br>
&gt; <br>
&gt; Created attachment 279297<br>
&gt;=C2=A0 =C2=A0--&gt; <a href=3D"https://bugzilla.kernel.org/attachment.c=
gi?id=3D279297&amp;action=3Dedit" rel=3D"noreferrer" target=3D"_blank">http=
s://bugzilla.kernel.org/attachment.cgi?id=3D279297&amp;action=3Dedit</a><br=
>
&gt; dmesg log of crash<br><br></blockquote><div><br></div><div>Basing on w=
hat I see in dmesg, it is highly likely to get fixed by=C2=A0<a href=3D"htt=
ps://lkml.org/lkml/2018/11/5/726">https://lkml.org/lkml/2018/11/5/726</a>. =
Could you please apply/retest?</div><div><br></div><div>Best regards,</div>=
<div>=C2=A0 =C2=A0Vitaly=C2=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding=
-left:1ex">
&gt; This happens mostly during memory pressure but I am not sure how to tr=
igger it<br>
&gt; reliably. I am attaching the full log.<br>
&gt; <br>
&gt; This is the kernel commandline<br>
&gt; <br>
&gt; &gt;BOOT_IMAGE=3D../vmlinuz-linux root=3DUUID=3D57274b3a-92ab-468e-b03=
a-06026675c1af rw<br>
&gt; &gt;<a href=3D"http://rd.luks.name" rel=3D"noreferrer" target=3D"_blan=
k">rd.luks.name</a>=3D92b4aeb2-fb97-45c1-8a60-2816efe5d57e=3Dhome resume=3D=
/dev/mapper/home<br>
&gt; &gt;resume_offset=3D42772480 acpi_backlight=3Dvideo zswap.enabled=3D1 =
zswap.zpool=3Dz3fold<br>
&gt; &gt;zswap.max_pool_percent=3D5 transparent_hugepage=3Dmadvise scsi_mod=
.use_blk_mq=3D1<br>
&gt; &gt;vga=3Dcurrent initrd=3D../intel-ucode.img,../initramfs-linux.img<b=
r>
&gt; <br>
&gt; I found this bug <a href=3D"https://bugzilla.kernel.org/show_bug.cgi?i=
d=3D198585" rel=3D"noreferrer" target=3D"_blank">https://bugzilla.kernel.or=
g/show_bug.cgi?id=3D198585</a> to be very<br>
&gt; similar but the proposed fix has not been merged so I can&#39;t be sur=
e if it will<br>
&gt; fix the issue I am having.<br>
&gt; <br>
&gt; -- <br>
&gt; You are receiving this mail because:<br>
&gt; You are the assignee for the bug.<br>
</blockquote></div></div></div>

--0000000000009cecf6057a064557--
