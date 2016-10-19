Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 655C4280250
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 14:36:52 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id t22so27610986vkb.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:36:52 -0700 (PDT)
Received: from mail-vk0-x22f.google.com (mail-vk0-x22f.google.com. [2607:f8b0:400c:c05::22f])
        by mx.google.com with ESMTPS id v141si5814918vkv.101.2016.10.19.11.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 11:36:51 -0700 (PDT)
Received: by mail-vk0-x22f.google.com with SMTP id 2so39069245vkb.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:36:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87y41kjn6l.fsf@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org> <20161018135031.GB13117@dhcp22.suse.cz>
 <8737jt903u.fsf@xmission.com> <20161018150507.GP14666@pc.thejh.net>
 <87twc9656s.fsf@xmission.com> <20161018191206.GA1210@laptop.thejh.net>
 <87r37dnz74.fsf@xmission.com> <87k2d5nytz.fsf_-_@xmission.com>
 <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com> <87y41kjn6l.fsf@xmission.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 19 Oct 2016 11:36:30 -0700
Message-ID: <CALCETrXMZ-3_T5Bucfyeh2nusLjOe50E1MoM3mRNzjrNkJppzg@mail.gmail.com>
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not read.
Content-Type: multipart/alternative; boundary=001a114e5a44a94c3e053f3c170e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Michal Hocko <mhocko@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Containers <containers@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

--001a114e5a44a94c3e053f3c170e
Content-Type: text/plain; charset=UTF-8

On Oct 19, 2016 9:54 AM, "Eric W. Biederman" <ebiederm@xmission.com> wrote:
>
> Andy Lutomirski <luto@amacapital.net> writes:
>
> > On Tue, Oct 18, 2016 at 2:15 PM, Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> >>
> >> When the user namespace support was merged the need to prevent
> >> ptracing an executable that is not readable was overlooked.
> >
> > Before getting too excited about this fix, isn't there a much bigger
> > hole that's been there forever?
>
> In this case it was a newish hole (2011) that the user namespace support
> added that I am closing.  I am not super excited but I figure it is
> useful to make the kernel semantics at least as secure as they were
> before.
>

But if it was never secure in the first place...

> > Simply ptrace yourself, exec the
> > program, and then dump the program out.  A program that really wants
> > to be unreadable should have a stub: the stub is setuid and readable,
> > but all the stub does is to exec the real program, and the real
> > program should have mode 0500 or similar.
> >
> > ISTM the "right" check would be to enforce that the program's new
> > creds can read the program, but that will break backwards
> > compatibility.
>
> Last I looked I had the impression that exec of a setuid program kills
> the ptrace.

I thought it killed the setuid, not the ptrace.

(I ought to know because I rewrote that code back in 2005 or so back when I
thought kernel programming was only for the cool kids.  It was probably my
first kernel patch ever and it fixed an awkward-to-exploit race.  But it's
been a while.)

--001a114e5a44a94c3e053f3c170e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><p dir=3D"ltr"></p>
<p dir=3D"ltr">On Oct 19, 2016 9:54 AM, &quot;Eric W. Biederman&quot; &lt;<=
a href=3D"mailto:ebiederm@xmission.com" target=3D"_blank">ebiederm@xmission=
.com</a>&gt; wrote:<br>
&gt;<br>
&gt; Andy Lutomirski &lt;<a href=3D"mailto:luto@amacapital.net" target=3D"_=
blank">luto@amacapital.net</a>&gt; writes:<br>
&gt;<br>
&gt; &gt; On Tue, Oct 18, 2016 at 2:15 PM, Eric W. Biederman<br>
&gt; &gt; &lt;<a href=3D"mailto:ebiederm@xmission.com" target=3D"_blank">eb=
iederm@xmission.com</a>&gt; wrote:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; When the user namespace support was merged the need to preven=
t<br>
&gt; &gt;&gt; ptracing an executable that is not readable was overlooked.<b=
r>
&gt; &gt;<br>
&gt; &gt; Before getting too excited about this fix, isn&#39;t there a much=
 bigger<br>
&gt; &gt; hole that&#39;s been there forever?<br>
&gt;<br>
&gt; In this case it was a newish hole (2011) that the user namespace suppo=
rt<br>
&gt; added that I am closing.=C2=A0 I am not super excited but I figure it =
is<br>
&gt; useful to make the kernel semantics at least as secure as they were<br=
>
&gt; before.<br>
&gt;</p>
<p dir=3D"ltr">But if it was never secure in the first place...</p>
<p dir=3D"ltr">&gt; &gt; Simply ptrace yourself, exec the<br>
&gt; &gt; program, and then dump the program out.=C2=A0 A program that real=
ly wants<br>
&gt; &gt; to be unreadable should have a stub: the stub is setuid and reada=
ble,<br>
&gt; &gt; but all the stub does is to exec the real program, and the real<b=
r>
&gt; &gt; program should have mode 0500 or similar.<br>
&gt; &gt;<br>
&gt; &gt; ISTM the &quot;right&quot; check would be to enforce that the pro=
gram&#39;s new<br>
&gt; &gt; creds can read the program, but that will break backwards<br>
&gt; &gt; compatibility.<br>
&gt;<br>
&gt; Last I looked I had the impression that exec of a setuid program kills=
<br>
&gt; the ptrace.</p>
<p dir=3D"ltr">I thought it killed the setuid, not the ptrace.</p>
<p dir=3D"ltr">(I ought to know because I rewrote that code back in 2005 or=
 so back when I thought kernel programming was only for the cool kids.=C2=
=A0 It was probably my first kernel patch ever and it fixed an awkward-to-e=
xploit race.=C2=A0 But it&#39;s been a while.)</p>
</div>

--001a114e5a44a94c3e053f3c170e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
