Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E62E6B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 11:16:06 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t9so49001599oih.13
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:16:06 -0700 (PDT)
Received: from mail-pf0-x23d.google.com (mail-pf0-x23d.google.com. [2607:f8b0:400e:c00::23d])
        by mx.google.com with ESMTPS id l7si5794350otd.181.2017.06.01.08.16.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 08:16:05 -0700 (PDT)
Received: by mail-pf0-x23d.google.com with SMTP id p70so4015658pfd.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:16:05 -0700 (PDT)
Date: Thu, 1 Jun 2017 08:16:03 -0700 (PDT)
From: =?UTF-8?B?546L6Z2W5aSp?= <ifqqfi@gmail.com>
Message-Id: <7548984c-57c4-42a6-96a4-972f5405bc85@googlegroups.com>
In-Reply-To: <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop>
 <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop>
 <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
 <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
 <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_575_1074923699.1496330164030"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kasan-dev <kasan-dev@googlegroups.com>
Cc: dvyukov@google.com, js1304@gmail.com, akpm@linux-foundation.org, glider@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, kernel-team@lge.com, aryabinin@virtuozzo.com

------=_Part_575_1074923699.1496330164030
Content-Type: multipart/alternative;
	boundary="----=_Part_576_1928279626.1496330164030"

------=_Part_576_1928279626.1496330164030
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit



>
> > But the main win as I see it is that that's basically complete support 
> > for 32-bit arches. People do ask about arm32 support: 
> > https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ 
> > https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ 
> > and probably mips32 is relevant as well. 
>
> I don't see how above is relevant for 32-bit arches. Current design 
> is perfectly fine for 32-bit arches. I did some POC arm32 port couple 
> years 
> ago - https://github.com/aryabinin/linux/commits/kasan/arm_v0_1 
> It has some ugly hacks and non-critical bugs. AFAIR it also super-slow 
> because I (mistakenly) 
> made shadow memory uncached. But otherwise it works. 
>
>
how many memory does this need, I want to use kasan on my system to debug 
some issue. It only has 256MB memory, 70MB free memory. 
and could you fix the super-slow problem?  

------=_Part_576_1928279626.1496330164030
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<div class=3D"IVILX2C-Db-b"><br></div><div><blockquote class=3D"gmail_quote=
" style=3D"margin: 0;margin-left: 0.8ex;border-left: 1px #ccc solid;padding=
-left: 1ex;"><br>&gt; But the main win as I see it is that that&#39;s basic=
ally complete support
<br>&gt; for 32-bit arches. People do ask about arm32 support:
<br>&gt; <a href=3D"https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/G=
qh4oD_wAAAJ" target=3D"_blank" rel=3D"nofollow" onmousedown=3D"this.href=3D=
&#39;https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ&#39=
;;return true;" onclick=3D"this.href=3D&#39;https://groups.google.com/d/msg=
/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ&#39;;return true;">https://groups.googl=
e.com/d/<wbr>msg/kasan-dev/Sk6BsSPMRRc/<wbr>Gqh4oD_wAAAJ</a>
<br>&gt; <a href=3D"https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/E=
VJPbrsgAgAJ" target=3D"_blank" rel=3D"nofollow" onmousedown=3D"this.href=3D=
&#39;https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ&#39=
;;return true;" onclick=3D"this.href=3D&#39;https://groups.google.com/d/msg=
/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ&#39;;return true;">https://groups.googl=
e.com/d/<wbr>msg/kasan-dev/B22vOFp-QWg/<wbr>EVJPbrsgAgAJ</a>
<br>&gt; and probably mips32 is relevant as well.
<br>
<br>I don&#39;t see how above is relevant for 32-bit arches. Current design
<br>is perfectly fine for 32-bit arches. I did some POC arm32 port couple y=
ears
<br>ago - <a href=3D"https://github.com/aryabinin/linux/commits/kasan/arm_v=
0_1" target=3D"_blank" rel=3D"nofollow" onmousedown=3D"this.href=3D&#39;htt=
ps://www.google.com/url?q\x3dhttps%3A%2F%2Fgithub.com%2Faryabinin%2Flinux%2=
Fcommits%2Fkasan%2Farm_v0_1\x26sa\x3dD\x26sntz\x3d1\x26usg\x3dAFQjCNHe6ASYv=
IhTKeF0bpWFjDxojBEGLA&#39;;return true;" onclick=3D"this.href=3D&#39;https:=
//www.google.com/url?q\x3dhttps%3A%2F%2Fgithub.com%2Faryabinin%2Flinux%2Fco=
mmits%2Fkasan%2Farm_v0_1\x26sa\x3dD\x26sntz\x3d1\x26usg\x3dAFQjCNHe6ASYvIhT=
KeF0bpWFjDxojBEGLA&#39;;return true;">https://github.com/aryabinin/<wbr>lin=
ux/commits/kasan/arm_v0_1</a>
<br>It has some ugly hacks and non-critical bugs. AFAIR it also super-slow =
because I (mistakenly)=20
<br>made shadow memory uncached. But otherwise it works.
<br><br></blockquote><div><br></div><div>how many memory does this need, I =
want to use kasan on my system to debug some issue. It only has 256MB memor=
y, 70MB free memory.=C2=A0</div><div>and could you fix the super-slow probl=
em? =C2=A0</div></div>
------=_Part_576_1928279626.1496330164030--

------=_Part_575_1074923699.1496330164030--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
