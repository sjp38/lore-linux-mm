Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 622926B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:43:53 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v137-v6so12738228oie.11
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:43:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 48-v6sor456018oty.29.2018.03.27.06.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 06:43:52 -0700 (PDT)
MIME-Version: 1.0
References: <2AD939572F25A448A3AE3CAEA61328C23750D4E0@BC-MAIL-M28.internal.baidu.com>
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C23750D4E0@BC-MAIL-M28.internal.baidu.com>
From: Austin Kim <austincrashtool@gmail.com>
Date: Tue, 27 Mar 2018 13:43:41 +0000
Message-ID: <CAKEcN828eqXN8zhKgzu+Mf-vdXC8o_LOmxwWZ4vayrdvmpdPFQ@mail.gmail.com>
Subject: Re: Too easy OOM
Content-Type: multipart/alternative; boundary="000000000000ba04aa05686514df"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--000000000000ba04aa05686514df
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Would you please specify the Linux Kernel version with reproducing rate?

If possible, please share the kernel log with .config.

BR
Austin Kim

2018=EB=85=84 3=EC=9B=94 27=EC=9D=BC (=ED=99=94) =EC=98=A4=ED=9B=84 6:19, L=
i,Rongqing <lirongqing@baidu.com>=EB=8B=98=EC=9D=B4 =EC=9E=91=EC=84=B1:

> Current kernel version is too easy to trigger OOM, is it normal?
>
>
>
> # echo $$ > /cgroup/test/tasks
>
> # echo 200000000 >/cgroup/test/memory.limit_in_bytes
>
> # dd if=3Daaa  of=3Dbbb  bs=3D1k count=3D3886080
>
> Killed
>

--000000000000ba04aa05686514df
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div>Would you please specify the Linux Kernel version wi=
th reproducing rate?=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D"aut=
o">If possible, please share the kernel log with .config.</div><div dir=3D"=
auto"><br></div><div dir=3D"auto">BR=C2=A0</div><div dir=3D"auto">Austin Ki=
m<br><br><div class=3D"gmail_quote" dir=3D"auto"><div dir=3D"ltr">2018=EB=
=85=84 3=EC=9B=94 27=EC=9D=BC (=ED=99=94) =EC=98=A4=ED=9B=84 6:19, Li,Rongq=
ing &lt;<a href=3D"mailto:lirongqing@baidu.com">lirongqing@baidu.com</a>&gt=
;=EB=8B=98=EC=9D=B4 =EC=9E=91=EC=84=B1:<br></div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex">





<div lang=3D"ZH-CN" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"m_6882307201516237202WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">Current kernel version is too e=
asy to trigger OOM, is it normal?<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><u></u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"># echo $$ &gt; /cgroup/test/tas=
ks<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"># echo 200000000 &gt;/cgroup/te=
st/memory.limit_in_bytes<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"># dd if=3Daaa=C2=A0 of=3Dbbb=C2=
=A0 bs=3D1k count=3D3886080<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Killed<u></u><u></u></span></p>
</div>
</div>

</blockquote></div></div></div>

--000000000000ba04aa05686514df--
