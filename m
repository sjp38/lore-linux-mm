Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01C17C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:56:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F5320C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:56:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WtMpa3kY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F5320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 359596B0007; Tue,  6 Aug 2019 10:56:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E557C6B0008; Tue,  6 Aug 2019 10:56:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCDF56B000A; Tue,  6 Aug 2019 10:56:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC13F6B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:56:01 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id x71so29109317vkd.15
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 07:56:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xR5fQJLGVnnHb0V6SPUZS3hYRLyPHMF1XQCS/xK5yLI=;
        b=gNgLarK6b3JsJeCs7AhDbtKjlnI9LsDlipa0agycp1/4/aVLk1ZDvhaczuRnC/6q0y
         kv4SXvxkkeOHGuvuObwN7W22tCeilaxUIkVapkhyJ1R01ahxogfaJtO/DT6QWa2gMxhe
         qXS/qOWb+WdGltCc0CRb0bFNtJJj5NaSxzxw4jQVIR+4WEygDRSerxH8n8utEk1izFdc
         22yntfQLrFYF2g29TK8zSjjVbPXOHvPNiPrcDfuNHD4LhVahqULl7FPmsQPsMv4pffAz
         XcDyKyIq30KhvOlbMUS4XKmiCbP/eRF3Osv/AR66u0D2VR6uk971wyYraHS6t//tDznD
         3miQ==
X-Gm-Message-State: APjAAAXJwnEInPkeyR8wDggDL8DVBHQgmLMhI6cv4/fMrtNC9JxYn+bR
	oo3mgBCYg6Gp3hK0aXgOvH9P9JIMRH3bFeZxhy56QD/BuqOB7eFWG6sVbvgFpMYV3+PxeyLCPHz
	JEjiEKpIpDmWjobqN4qt9x0F4bnm7RUf3U/Y4mFUSUFsdNBzSi06WTQX38vXZ0PuTSg==
X-Received: by 2002:a67:fd91:: with SMTP id k17mr2555764vsq.121.1565103361408;
        Tue, 06 Aug 2019 07:56:01 -0700 (PDT)
X-Received: by 2002:a67:fd91:: with SMTP id k17mr2555739vsq.121.1565103360770;
        Tue, 06 Aug 2019 07:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565103360; cv=none;
        d=google.com; s=arc-20160816;
        b=Df622b47AhTYZlVtxhSB3aScFMDR8rG/t3NYtsIksBb1mokeNvaaK2/iBWTx5tkGTK
         tiaR6fQORAcZCYGZiGrl+18kkKytdjIJvQHe1TwHC+bBlgeJ7B0y8KjZXsU1MoEcQTmj
         eN5ayGB6Atk2RUJKeqzdOlWVjpbVfRU+H5ND0NoX+58UEAJVdD0+X+AmONUPTyvqcAsC
         uj3FOWsyFq/CaACj8APv70U8uQgSrjjC2cYRB9rWl/WDtCXZ/Ne+lF7LsX8qWlbbTSMr
         KJjNmvzFBXrm8Osucb63cGOLIviV7zM9mlhE8qVPJuHHt2DTOBfBEXAEUyGX0IAmrro3
         pQzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xR5fQJLGVnnHb0V6SPUZS3hYRLyPHMF1XQCS/xK5yLI=;
        b=VxJeJ7FD7w8nkkmqbwDH4ik9SUaio+O2bBi6ZY/Fou4iuCzwyHG2waeIt6X/wowyZB
         zxwjb0qbT17StDbDaiDIPYbkQY/eY75KTMIHQhfAOZSIf6E4aq+GJw+cDcMxp+Qjj/gH
         EzPKYrD2NImSP4PFprqgYM7+oCacT+knDKdgg5GmRRucpbTzRc9ufvQs2pXHFvI/8+Df
         pGrgWzR9VMPmd6+gaq58UsWt+P6JHt/dGfwSAnaHt8jJ1Fs6myRC/eAHIa7IOdwX4x6K
         NVJ62Es0ogsqw0NQRzAvn9+juGYZXGM0Jg5+qovKz1t+etgT9UZJE2TkssoLkPP10tV2
         b8pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WtMpa3kY;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 197sor25599713vkg.17.2019.08.06.07.56.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 07:56:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WtMpa3kY;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xR5fQJLGVnnHb0V6SPUZS3hYRLyPHMF1XQCS/xK5yLI=;
        b=WtMpa3kYN337E2Jx/xjsL/IXUbgsajyuzAJ4mh2uwR6/N6TlRdcdHGeRI40P0sWP49
         zLQ9kBin8DxiMt06eWPsPxhf5Y+E6ou1nPJTU9hNcXtLE/esQUVcHn/cDl7huSO7IcSV
         1ol6qXUK8HkYKiBeA/yXcsw7jVp9msJrxAfA+lLjJNqhHhK1tDS3XKObXqJErVudtmVv
         rWi2wC5CVIDpCvA1GcNapw2IvhRZ3nZmgJP/yDu13/EvTTX08nhGGNb/z5fWRA9XDvBd
         w+1taZza265wa2aGG4LV1K6/KvL+jattk3E++QcSCz752oXnE3Oy7Dyd5FGbb2jy6Iz5
         m5/Q==
X-Google-Smtp-Source: APXvYqwew+zqN5ojq3/pGZdHRktkO13zYZjrMMfxcxYgKPCDyreKw6FZJWMQZW3rx3j0nkBbEgGvsTFTC8MxW7Hiye0=
X-Received: by 2002:a1f:ee0a:: with SMTP id m10mr1369422vkh.73.1565103360362;
 Tue, 06 Aug 2019 07:56:00 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz> <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz> <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
 <df820f66-cf82-b43f-97b6-c92a116fa1a6@suse.cz>
In-Reply-To: <df820f66-cf82-b43f-97b6-c92a116fa1a6@suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Tue, 6 Aug 2019 20:25:51 +0530
Message-ID: <CACDBo57Yjuc69GX+V7w_efSHPkpeU3D9RUr0TEd64oUTi4o8Ag@mail.gmail.com>
Subject: Re: oom-killer
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	pankaj.suryawanshi@einfochips.com
Content-Type: multipart/alternative; boundary="000000000000d4ccce058f740517"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000d4ccce058f740517
Content-Type: text/plain; charset="UTF-8"

On Tue, Aug 6, 2019 at 3:34 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 8/5/19 5:34 PM, Pankaj Suryawanshi wrote:
> > On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> >>
> >> On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> >> > On 8/5/19 1:24 PM, Michal Hocko wrote:
> >> > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P
    O  4.14.65 #606
> >> > > [...]
> >> > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>]
(out_of_memory+0x140/0x368)
> >> > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680
r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> >> > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]
 (__alloc_pages_nodemask+0x1178/0x124c)
> >> > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> >> > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from
[<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> >> > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08
r6:c1216588 r5:00808111
> >> > >> [  728.079587]  r4:d1063c00
> >> > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from
[<c0220470>] (_do_fork+0xd0/0x464)
> >> > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000
r6:c1216588 r5:d2d58ac0
> >> > >> [  728.097857]  r4:00808111
> >> > >
> >> > > The call trace tells that this is a fork (of a usermodhlper but
that is
> >> > > not all that important.
> >> > > [...]
> >> > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB
high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB
inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB
managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB
bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
> >> > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> >> > >
> >> > > So this is the only usable zone and you are close to the min
watermark
> >> > > which means that your system is under a serious memory pressure
but not
> >> > > yet under OOM for order-0 request. The situation is not great
though
> >> >
> >> > Looking at lowmem_reserve above, wonder if 579 applies here? What
does
> >> > /proc/zoneinfo say?
> >
> >
> > What is  lowmem_reserve[]: 0 0 579 579 ?
> >
> > $cat /proc/sys/vm/lowmem_reserve_ratio
> > 256     32      32
> >
> > $cat /proc/sys/vm/min_free_kbytes
> > 16384
> >
> > here is cat /proc/zoneinfo (in normal situation not when oom)
>
> Thanks, that shows the lowmem reserve was indeed 0 for the GFP_KERNEL
allocation
> checking watermarks in the DMA zone. The zone was probably genuinely
below min
> watermark when the check happened, and things changed while the allocation
> failure was printing memory info.
Thanks Vlastimil.

lowmem reserve ? it is min_free_kbytes or something else.

--000000000000d4ccce058f740517
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Tue, Aug 6, 2019 at 3:34 PM Vlastimil Babka &lt=
;<a href=3D"mailto:vbabka@suse.cz">vbabka@suse.cz</a>&gt; wrote:<br>&gt;<br=
>&gt; On 8/5/19 5:34 PM, Pankaj Suryawanshi wrote:<br>&gt; &gt; On Mon, Aug=
 5, 2019 at 5:35 PM Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org">m=
hocko@kernel.org</a>&gt; wrote:<br>&gt; &gt;&gt;<br>&gt; &gt;&gt; On Mon 05=
-08-19 13:56:20, Vlastimil Babka wrote:<br>&gt; &gt;&gt; &gt; On 8/5/19 1:2=
4 PM, Michal Hocko wrote:<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A0727.954355=
] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 O =C2=A04.14.65 #606<br>&gt; &gt;&gt; &gt; &gt; [...]<br>&gt; &gt;&g=
t; &gt; &gt;&gt; [ =C2=A0728.029390] [&lt;c034a094&gt;] (oom_kill_process) =
from [&lt;c034af24&gt;] (out_of_memory+0x140/0x368)<br>&gt; &gt;&gt; &gt; &=
gt;&gt; [ =C2=A0728.037569] =C2=A0r10:00000001 r9:c12169bc r8:00000041 r7:c=
121e680 r6:c1216588 r5:dd347d7c &gt; [ =C2=A0728.045392] =C2=A0r4:d5737080<=
br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A0728.047929] [&lt;c034ade4&gt;] (out_=
of_memory) from [&lt;c03519ac&gt;] =C2=A0(__alloc_pages_nodemask+0x1178/0x1=
24c)<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A0728.056798] =C2=A0r7:c141e7d0 r=
6:c12166a4 r5:00000000 r4:00001155<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A07=
28.062460] [&lt;c0350834&gt;] (__alloc_pages_nodemask) from [&lt;c021e9d4&g=
t;] (copy_process.part.5+0x114/0x1a28)<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=
=A0728.071764] =C2=A0r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1=
216588 r5:00808111<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A0728.079587] =C2=
=A0r4:d1063c00<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A0728.082119] [&lt;c021=
e8c0&gt;] (copy_process.part.5) from [&lt;c0220470&gt;] (_do_fork+0xd0/0x46=
4)<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A0728.090034] =C2=A0r10:00000000 r9=
:00000000 r8:dd008400 r7:00000000 r6:c1216588 r5:d2d58ac0<br>&gt; &gt;&gt; =
&gt; &gt;&gt; [ =C2=A0728.097857] =C2=A0r4:00808111<br>&gt; &gt;&gt; &gt; &=
gt;<br>&gt; &gt;&gt; &gt; &gt; The call trace tells that this is a fork (of=
 a usermodhlper but that is<br>&gt; &gt;&gt; &gt; &gt; not all that importa=
nt.<br>&gt; &gt;&gt; &gt; &gt; [...]<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=
=A0728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB active=
_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB unevict=
able:0kB writepending:0kB present:458752kB managed:422896kB mlocked:0kB ker=
nel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB =
free_cma:0kB<br>&gt; &gt;&gt; &gt; &gt;&gt; [ =C2=A0728.287402] lowmem_rese=
rve[]: 0 0 579 579<br>&gt; &gt;&gt; &gt; &gt;<br>&gt; &gt;&gt; &gt; &gt; So=
 this is the only usable zone and you are close to the min watermark<br>&gt=
; &gt;&gt; &gt; &gt; which means that your system is under a serious memory=
 pressure but not<br>&gt; &gt;&gt; &gt; &gt; yet under OOM for order-0 requ=
est. The situation is not great though<br>&gt; &gt;&gt; &gt;<br>&gt; &gt;&g=
t; &gt; Looking at lowmem_reserve above, wonder if 579 applies here? What d=
oes<br>&gt; &gt;&gt; &gt; /proc/zoneinfo say?<br>&gt; &gt;<br>&gt; &gt;<br>=
&gt; &gt; What is =C2=A0lowmem_reserve[]: 0 0 579 579 ?<br>&gt; &gt;<br>&gt=
; &gt; $cat /proc/sys/vm/lowmem_reserve_ratio<br>&gt; &gt; 256 =C2=A0 =C2=
=A0 32 =C2=A0 =C2=A0 =C2=A032<br>&gt; &gt;<br>&gt; &gt; $cat /proc/sys/vm/m=
in_free_kbytes<br>&gt; &gt; 16384<br>&gt; &gt;<br>&gt; &gt; here is cat /pr=
oc/zoneinfo (in normal situation not when oom)<br>&gt;<br>&gt; Thanks, that=
 shows the lowmem reserve was indeed 0 for the GFP_KERNEL allocation<br>&gt=
; checking watermarks in the DMA zone. The zone was probably genuinely belo=
w min<br>&gt; watermark when the check happened, and things changed while t=
he allocation<br>&gt; failure was printing memory info.<div>Thanks Vlastimi=
l.=C2=A0</div><div><br></div><div>lowmem reserve ? it is min_free_kbytes or=
 something else.</div></div>

--000000000000d4ccce058f740517--

