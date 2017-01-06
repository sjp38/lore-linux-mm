Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5A26B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:37:42 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id p127so576764114iop.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:37:42 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id a188si3509835ioa.136.2017.01.06.07.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 07:37:41 -0800 (PST)
Received: by mail-io0-x22b.google.com with SMTP id v96so34876572ioi.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:37:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170106152052.GS5556@dhcp22.suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz>
From: Eric Dumazet <edumazet@google.com>
Date: Fri, 6 Jan 2017 07:37:41 -0800
Message-ID: <CANn89iLEOM2UpADkAqCkL5FQTG9-qgHgDevUDwgFAjWKbSOMzw@mail.gmail.com>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Content-Type: multipart/alternative; boundary=001a11409dee68425b05456eccfc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

--001a11409dee68425b05456eccfc
Content-Type: text/plain; charset=UTF-8

On Fri, Jan 6, 2017 at 7:20 AM, Michal Hocko <mhocko@kernel.org> wrote:

> Hi Eric,
> I am currently checking kmalloc with vmalloc fallback users and convert
> them to a new kvmalloc helper [1]. While I am adding a support for
> __GFP_REPEAT to kvmalloc [2] I was wondering what is the reason to use
> __GFP_REPEAT in fq_alloc_node in the first place. c3bd85495aef
> ("pkt_sched: fq: more robust memory allocation") doesn't mention
> anything. Could you clarify this please?
>
> Thanks!
>
> [1] http://lkml.kernel.org/r/20170102133700.1734-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20170104181229.GB10183@dhcp22.suse.cz
> --
> Michal Hocko
> SUSE Labs
>

At the time, tests on the hardware I had in my labs showed that vmalloc()
could deliver pages spread
all over the memory and that was a small penalty (once memory is fragmented
enough, not at boot time)

I guess this wont be anymore a concern if I can finish my pending work
about vmalloc() trying to get adjacent pages
https://lkml.org/lkml/2016/12/21/285

Thanks.

--001a11409dee68425b05456eccfc
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Fri, Jan 6, 2017 at 7:20 AM, Michal Hocko <span dir=3D"ltr">&lt;<a h=
ref=3D"mailto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt=
;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0p=
x 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">Hi Eri=
c,<br>
I am currently checking kmalloc with vmalloc fallback users and convert<br>
them to a new kvmalloc helper [1]. While I am adding a support for<br>
__GFP_REPEAT to kvmalloc [2] I was wondering what is the reason to use<br>
__GFP_REPEAT in fq_alloc_node in the first place. c3bd85495aef<br>
(&quot;pkt_sched: fq: more robust memory allocation&quot;) doesn&#39;t ment=
ion<br>
anything. Could you clarify this please?<br>
<br>
Thanks!<br>
<br>
[1] <a href=3D"http://lkml.kernel.org/r/20170102133700.1734-1-mhocko@kernel=
.org" rel=3D"noreferrer" target=3D"_blank">http://lkml.kernel.org/r/<wbr>20=
170102133700.1734-1-mhocko@<wbr>kernel.org</a><br>
[2] <a href=3D"http://lkml.kernel.org/r/20170104181229.GB10183@dhcp22.suse.=
cz" rel=3D"noreferrer" target=3D"_blank">http://lkml.kernel.org/r/<wbr>2017=
0104181229.GB10183@dhcp22.<wbr>suse.cz</a><br>
<span class=3D"gmail-HOEnZb"><font color=3D"#888888">--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div><div class=3D"gmail_extra">At th=
e time, tests on the hardware I had in my labs showed that vmalloc() could =
deliver pages spread</div><div class=3D"gmail_extra">all over the memory an=
d that was a small penalty (once memory is fragmented enough, not at boot t=
ime)</div><div class=3D"gmail_extra"><br></div><div class=3D"gmail_extra">I=
 guess this wont be anymore a concern if I can finish my pending work about=
 vmalloc() trying to get adjacent pages</div><div class=3D"gmail_extra"><a =
href=3D"https://lkml.org/lkml/2016/12/21/285">https://lkml.org/lkml/2016/12=
/21/285</a><br><br></div><div class=3D"gmail_extra">Thanks.</div><div class=
=3D"gmail_extra"><br></div><div class=3D"gmail_extra"><br></div></div>

--001a11409dee68425b05456eccfc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
