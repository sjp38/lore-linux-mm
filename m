Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2FE6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 00:27:26 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 78so13100649otj.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 21:27:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor2576287ota.190.2018.01.17.21.27.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 21:27:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180116145240.GD30073@bombadil.infradead.org>
References: <20180116145240.GD30073@bombadil.infradead.org>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 18 Jan 2018 13:27:24 +0800
Message-ID: <CAF7GXvonnUNGMWXnR1gM0LhqQ_gjktcv50V7WGdBtbufbc-8eg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] A high-performance userspace block driver
Content-Type: multipart/alternative; boundary="001a113d1a1c0b50ca05630638d1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org

--001a113d1a1c0b50ca05630638d1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

2018-01-16 22:52 GMT+08:00 Matthew Wilcox <willy@infradead.org>:

>
> I see the improvements that Facebook have been making to the nbd driver,
> and I think that's a wonderful thing.  Maybe the outcome of this topic
> is simply: "Shut up, Matthew, this is good enough".
>
> It's clear that there's an appetite for userspace block devices; not for
> swap devices or the root device, but for accessing data that's stored
> in that silo over there, and I really don't want to bring that entire
> mess of CORBA / Go / Rust / whatever into the kernel to get to it,
> but it would be really handy to present it as a block device.
>
> I've looked at a few block-driver-in-userspace projects that exist, and
> they all seem pretty bad.


how about the SPDK=EF=BC=9F


> For example, one API maps a few gigabytes of
> address space and plays games with vm_insert_page() to put page cache
> pages into the address space of the client process.  Of course, the TLB
> flush overhead of that solution is criminal.
>
> I've looked at pipes, and they're not an awful solution.  We've almost
> got enough syscalls to treat other objects as pipes.  The problem is
> that they're not seekable.  So essentially you're looking at having one
> pipe per outstanding command.  If yu want to make good use of a modern
> NAND device, you want a few hundred outstanding commands, and that's a
> bit of a shoddy interface.
>
> Right now, I'm leaning towards combining these two approaches; adding
> a VM_NOTLB flag so the mmaped bits of the page cache never make it into
> the process's address space, so the TLB shootdown can be safely skipped.
> Then check it in follow_page_mask() and return the appropriate struct
> page.  As long as the userspace process does everything using O_DIRECT,
> I think this will work.
>
> It's either that or make pipes seekable ...
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a113d1a1c0b50ca05630638d1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2018-01-16 22:52 GMT+08:00 Matthew Wilcox <span dir=3D"ltr">&lt;<a href=
=3D"mailto:willy@infradead.org" target=3D"_blank">willy@infradead.org</a>&g=
t;</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex"><br>
I see the improvements that Facebook have been making to the nbd driver,<br=
>
and I think that&#39;s a wonderful thing.=C2=A0 Maybe the outcome of this t=
opic<br>
is simply: &quot;Shut up, Matthew, this is good enough&quot;.<br>
<br>
It&#39;s clear that there&#39;s an appetite for userspace block devices; no=
t for<br>
swap devices or the root device, but for accessing data that&#39;s stored<b=
r>
in that silo over there, and I really don&#39;t want to bring that entire<b=
r>
mess of CORBA / Go / Rust / whatever into the kernel to get to it,<br>
but it would be really handy to present it as a block device.<br>
<br>
I&#39;ve looked at a few block-driver-in-userspace projects that exist, and=
<br>
they all seem pretty bad.=C2=A0 </blockquote><div><br></div><div>how=C2=A0a=
bout=C2=A0the SPDK=EF=BC=9F</div><div>=C2=A0</div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">For example, one API maps a few gigabytes of<br>
address space and plays games with vm_insert_page() to put page cache<br>
pages into the address space of the client process.=C2=A0 Of course, the TL=
B<br>
flush overhead of that solution is criminal.<br>
<br>
I&#39;ve looked at pipes, and they&#39;re not an awful solution.=C2=A0 We&#=
39;ve almost<br>
got enough syscalls to treat other objects as pipes.=C2=A0 The problem is<b=
r>
that they&#39;re not seekable.=C2=A0 So essentially you&#39;re looking at h=
aving one<br>
pipe per outstanding command.=C2=A0 If yu want to make good use of a modern=
<br>
NAND device, you want a few hundred outstanding commands, and that&#39;s a<=
br>
bit of a shoddy interface.<br>
<br>
Right now, I&#39;m leaning towards combining these two approaches; adding<b=
r>
a VM_NOTLB flag so the mmaped bits of the page cache never make it into<br>
the process&#39;s address space, so the TLB shootdown can be safely skipped=
.<br>
Then check it in follow_page_mask() and return the appropriate struct<br>
page.=C2=A0 As long as the userspace process does everything using O_DIRECT=
,<br>
I think this will work.<br>
<br>
It&#39;s either that or make pipes seekable ...<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</blockquote></div><br></div></div>

--001a113d1a1c0b50ca05630638d1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
