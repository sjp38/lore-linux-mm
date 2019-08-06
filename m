Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDDB1C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:23:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 865232173B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:23:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cZpckIwA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 865232173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F9F86B000A; Tue,  6 Aug 2019 11:23:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 082FC6B000C; Tue,  6 Aug 2019 11:23:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E655A6B000D; Tue,  6 Aug 2019 11:23:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBE236B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:23:40 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id u24so8326392uah.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:23:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TYtqhix5oFQwT5ueQFJUzvVL5bD4y6Pf1JGB1N3mT/s=;
        b=P/16DmO09RpkQmjato5bx0f/mMukH1ANpepf0irYGPwuwSC/cPgdc38/I9Z6QaO9n/
         9oUjQS27DrFY1KRootIZ01eiYzR1ymQinHT3M2PlM55i3nJBcGBOGPbvw7ZHxLK19Gdq
         z4mSRzQ3KvSPliMYTZGA9e+xKDMukRYvIDelSBYwDjEIvdkWDxGbHfv6+xr6Qg5fIVjt
         jnZ9Lt/HyCe4w+1NN7YqC0/LydzQ13648K9geftlSr62lW+QdRoeQ7Gpqcc6779JV96d
         hQzRDvwCKjmZM1QBQVNoMjYSa01axN1mLz9b5epnSI9BoR69neHYHG24oJTIBRHweIni
         Wlqg==
X-Gm-Message-State: APjAAAWvOBmxmxSIVrllRLveaCIoX/nqwU1OUWdV9gzWUjAziDBZAh9L
	dAWXAC70TQ+coUZqiHlVtw4qCNlQfHnEAqhq1DDYhrIi5HIAJivq+dWjKU8+npyghPHUhgqvsqO
	X5BTiloYm38gsAblTnrYsxHzuOniXMUDJIdlBcFqgWvPDYD5B3eRuh0g5LS6tlD80TQ==
X-Received: by 2002:a67:8e48:: with SMTP id q69mr2722649vsd.72.1565105020470;
        Tue, 06 Aug 2019 08:23:40 -0700 (PDT)
X-Received: by 2002:a67:8e48:: with SMTP id q69mr2722609vsd.72.1565105019842;
        Tue, 06 Aug 2019 08:23:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565105019; cv=none;
        d=google.com; s=arc-20160816;
        b=nq2TH3hFug/H892EqVmhxi3vgwtjYK2dnet26opKTVHDKqSd/KYcB+9tT2vfOX1+ji
         suG3tSBn2xv7pKGfOoWA70caJltUoU9xS5mNBYn01NsbzZrilmZGnO59m0k+zCioE9yy
         D1XHOC8/V62aHhsWd41IUteGAkQPMuxqSHCYtaE9r/L+3iT3sXHtLMiD68e5XzReRYky
         MoDkPayqy8MdilrvcJL02BXonDKljrbF1CWiMYS//qnY4ZoV83380NqZaH+yn7GV08PF
         o5p2mQRBeLlcNxrsl7+k1RCEvxktmlCrZCseCHWs96entSzK/1zO8+7aTnHER2DuvqmU
         V/rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TYtqhix5oFQwT5ueQFJUzvVL5bD4y6Pf1JGB1N3mT/s=;
        b=Rw2T3McUOd+TawNu2nghIVgGdlzPcSqphagFVNutRrosKAUj/ul5FyCvnduMA748Oc
         ql/N7dDKgWBYUpgikkstwYcN0fR9hufr1V1yYXlbxBrnJtB+roeWXGPmsCri8GcnBEW7
         OgmSJKwmhkv3G1gPpUvwcQcdEq8sdbaXgY2NiWIZHJlQO+plx3ZRktKOeejT+vaqkDHT
         kocxJZiJUmoUHZSrvjQx3Lr1WzixGs/be6dDbaRvzn6BmJiWQTgB0P+DGRMR9D/dmo49
         QQ7jCOx9WlCrw5elhiFRRW5LJrvbP2qqyScIf0fnSmU7XTB7GUCqQHr9NhuiHfkIoqYh
         J5rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cZpckIwA;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k189sor43153457vsd.118.2019.08.06.08.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 08:23:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cZpckIwA;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TYtqhix5oFQwT5ueQFJUzvVL5bD4y6Pf1JGB1N3mT/s=;
        b=cZpckIwALBx6LL1/usfLJcpXl9O+9kEx2Msqwco1Jv9vl/5TnYEtfZ+ZnpO6Tx8ze0
         eSP1Yf73JfMPjPLZ8JvZWdEp2IMdauIlG1pTfvzy5AhMhNBN7h7PJXMZ9dmCIe+FB/Ck
         6oWBUvcFmkN9mOD7F6C2U7C2ocdTAciXp6IJN9Ce7WgnwLF7ZxLzRyHqNYOjhaAcu7TH
         ciW+/2FtQWFlys3AH35R0abMGfQdcSASKMVwyoAAjG2Rnqf4p1fbPhbrImj+jYZUzren
         97clNURUS64eN3gdCZ6c8MgCMeE9KxMe+E93Y1bfsG8E8+l6ZT9SmvNuQNfAtHgcVxH5
         c6NA==
X-Google-Smtp-Source: APXvYqz1jRf64/BGO86H1aY/AjDsFLEMHVUXnz3nMewxPZB4MqAsSObbZnCxl1yVaQT6c+mIMf9YKtPp3lcjCk5oWPg=
X-Received: by 2002:a67:ee16:: with SMTP id f22mr2675846vsp.191.1565105019396;
 Tue, 06 Aug 2019 08:23:39 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz> <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz> <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
 <20190805201650.GT7597@dhcp22.suse.cz> <CACDBo54kBy_YBcXBzs1dOxQRg+TKFQox_aqqtB2dvL+mmusDVg@mail.gmail.com>
 <20190806150733.GH11812@dhcp22.suse.cz> <CACDBo54KihsV=8NLGZkTghTzb2p70WURF2L5op=fW7DGj_vJ1A@mail.gmail.com>
 <20190806151251.GJ11812@dhcp22.suse.cz>
In-Reply-To: <20190806151251.GJ11812@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Tue, 6 Aug 2019 20:53:30 +0530
Message-ID: <CACDBo5622YYKGQMq1XzM_1V9S=pS4A0izQbouUZ7RoGB_ZTayg@mail.gmail.com>
Subject: Re: oom-killer
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	pankaj.suryawanshi@einfochips.com
Content-Type: multipart/alternative; boundary="000000000000b7a509058f7468f6"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000b7a509058f7468f6
Content-Type: text/plain; charset="UTF-8"

On Tue, Aug 6, 2019 at 8:42 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 20:39:22, Pankaj Suryawanshi wrote:
> > On Tue, Aug 6, 2019 at 8:37 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 06-08-19 20:24:03, Pankaj Suryawanshi wrote:
> > > > On Tue, 6 Aug, 2019, 1:46 AM Michal Hocko, <mhocko@kernel.org>
wrote:
> > > > >
> > > > > On Mon 05-08-19 21:04:53, Pankaj Suryawanshi wrote:
> > > > > > On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org>
wrote:
> > > > > > >
> > > > > > > On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> > > > > > > > On 8/5/19 1:24 PM, Michal Hocko wrote:
> > > > > > > > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2
Tainted: P           O  4.14.65 #606
> > > > > > > > > [...]
> > > > > > > > >> [  728.029390] [<c034a094>] (oom_kill_process) from
[<c034af24>] (out_of_memory+0x140/0x368)
> > > > > > > > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041
r7:c121e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> > > > > > > > >> [  728.047929] [<c034ade4>] (out_of_memory) from
[<c03519ac>]  (__alloc_pages_nodemask+0x1178/0x124c)
> > > > > > > > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000
r4:00001155
> > > > > > > > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask)
from [<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> > > > > > > > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000
r7:c1447e08 r6:c1216588 r5:00808111
> > > > > > > > >> [  728.079587]  r4:d1063c00
> > > > > > > > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from
[<c0220470>] (_do_fork+0xd0/0x464)
> > > > > > > > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400
r7:00000000 r6:c1216588 r5:d2d58ac0
> > > > > > > > >> [  728.097857]  r4:00808111
> > > > > > > > >
> > > > > > > > > The call trace tells that this is a fork (of a
usermodhlper but that is
> > > > > > > > > not all that important.
> > > > > > > > > [...]
> > > > > > > > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB
high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB
inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB
managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB
bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
> > > > > > > > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > > > > > > > >
> > > > > > > > > So this is the only usable zone and you are close to the
min watermark
> > > > > > > > > which means that your system is under a serious memory
pressure but not
> > > > > > > > > yet under OOM for order-0 request. The situation is not
great though
> > > > > > > > sometimes application(which cause to oom) works very
slowly(result of application/score opengl app which allocate memory for
graphics) and sometime it closed itself.
So the question is only Why their is difference in result when same oom
killer killing applications (on same system/same mode/same situation) ? How
to debug that because as you said oom killer dumped information after
everything okay ?
> > > > > > > > Looking at lowmem_reserve above, wonder if 579 applies
here? What does
> > > > > > > > /proc/zoneinfo say?
> > > > > >
> > > > > >
> > > > > > What is  lowmem_reserve[]: 0 0 579 579 ?
> > > > >
> > > > > This controls how much of memory from a lower zone you might an
> > > > > allocation request for a higher zone consume. E.g. __GFP_HIGHMEM
is
> > > > > allowed to use both lowmem and highmem zones. It is preferable to
use
> > > > > highmem zone because other requests are not allowed to use it.
> > > > >
> > > > > Please see __zone_watermark_ok for more details.
> > > > >
> > > > >
> > > > > > > This is GFP_KERNEL request essentially so there shouldn't be
any lowmem
> > > > > > > reserve here, no?
> > > > > >
> > > > > >
> > > > > > Why only low 1G is accessible by kernel in 32-bit system ?
> > > >
> > > >
> > > > 1G ivirtual or physical memory (I have 2GB of RAM) ?
> > >
> > > virtual
> > >
> >  I have set 2G/2G still it works ?
>
> It would reduce the amount of memory that userspace might use. It may
> work for your particular case but the fundamental restriction is still
> there

Thanks Michal..
> --
> Michal Hocko
> SUSE Labs

--000000000000b7a509058f7468f6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Tue, Aug 6, 2019 at 8:42 PM Michal Hocko &lt;<a=
 href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>&gt;=
<br>&gt; On Tue 06-08-19 20:39:22, Pankaj Suryawanshi wrote:<br>&gt; &gt; O=
n Tue, Aug 6, 2019 at 8:37 PM Michal Hocko &lt;<a href=3D"mailto:mhocko@ker=
nel.org">mhocko@kernel.org</a>&gt; wrote:<br>&gt; &gt; &gt;<br>&gt; &gt; &g=
t; On Tue 06-08-19 20:24:03, Pankaj Suryawanshi wrote:<br>&gt; &gt; &gt; &g=
t; On Tue, 6 Aug, 2019, 1:46 AM Michal Hocko, &lt;<a href=3D"mailto:mhocko@=
kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>&gt; &gt; &gt; &gt; &gt;<br=
>&gt; &gt; &gt; &gt; &gt; On Mon 05-08-19 21:04:53, Pankaj Suryawanshi wrot=
e:<br>&gt; &gt; &gt; &gt; &gt; &gt; On Mon, Aug 5, 2019 at 5:35 PM Michal H=
ocko &lt;<a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wro=
te:<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; &gt; &gt; =
&gt; On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:<br>&gt; &gt; &gt; &gt=
; &gt; &gt; &gt; &gt; On 8/5/19 1:24 PM, Michal Hocko wrote:<br>&gt; &gt; &=
gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =C2=A0727.954355] CPU: 0 PID: 56 Co=
mm: kworker/u8:2 Tainted: P =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 O =C2=A04.14=
.65 #606<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; [...]<br>&gt; &gt;=
 &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =C2=A0728.029390] [&lt;c034a094&g=
t;] (oom_kill_process) from [&lt;c034af24&gt;] (out_of_memory+0x140/0x368)<=
br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =C2=A0728.037569] =C2=
=A0r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c=
 &gt; [ =C2=A0728.045392] =C2=A0r4:d5737080<br>&gt; &gt; &gt; &gt; &gt; &gt=
; &gt; &gt; &gt;&gt; [ =C2=A0728.047929] [&lt;c034ade4&gt;] (out_of_memory)=
 from [&lt;c03519ac&gt;] =C2=A0(__alloc_pages_nodemask+0x1178/0x124c)<br>&g=
t; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =C2=A0728.056798] =C2=A0r7=
:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155<br>&gt; &gt; &gt; &gt; &gt; &=
gt; &gt; &gt; &gt;&gt; [ =C2=A0728.062460] [&lt;c0350834&gt;] (__alloc_page=
s_nodemask) from [&lt;c021e9d4&gt;] (copy_process.part.5+0x114/0x1a28)<br>&=
gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =C2=A0728.071764] =C2=A0r=
10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111<br>=
&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =C2=A0728.079587] =C2=A0=
r4:d1063c00<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =C2=A0728=
.082119] [&lt;c021e8c0&gt;] (copy_process.part.5) from [&lt;c0220470&gt;] (=
_do_fork+0xd0/0x464)<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [ =
=C2=A0728.090034] =C2=A0r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6=
:c1216588 r5:d2d58ac0<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&gt; [=
 =C2=A0728.097857] =C2=A0r4:00808111<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; =
&gt; &gt;<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; The call trace te=
lls that this is a fork (of a usermodhlper but that is<br>&gt; &gt; &gt; &g=
t; &gt; &gt; &gt; &gt; &gt; not all that important.<br>&gt; &gt; &gt; &gt; =
&gt; &gt; &gt; &gt; &gt; [...]<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &=
gt;&gt; [ =C2=A0728.260031] DMA free:17960kB min:16384kB low:25664kB high:2=
9760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file=
:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB ml=
ocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB l=
ocal_pcp:0kB free_cma:0kB<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt;&g=
t; [ =C2=A0728.287402] lowmem_reserve[]: 0 0 579 579<br>&gt; &gt; &gt; &gt;=
 &gt; &gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; S=
o this is the only usable zone and you are close to the min watermark<br>&g=
t; &gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; which means that your system is =
under a serious memory pressure but not<br>&gt; &gt; &gt; &gt; &gt; &gt; &g=
t; &gt; &gt; yet under OOM for order-0 request. The situation is not great =
though<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; sometimes application(whi=
ch cause to oom) works very slowly(result of application/score opengl app w=
hich allocate memory for graphics) and sometime it closed itself.=C2=A0<div=
>So the question is only Why their is difference in result when same oom ki=
ller killing applications (on same system/same mode/same situation) ? How t=
o debug that because as you said oom killer dumped information after everyt=
hing okay ?<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; &gt; Looking at lowmem_re=
serve above, wonder if 579 applies here? What does<br>&gt; &gt; &gt; &gt; &=
gt; &gt; &gt; &gt; /proc/zoneinfo say?<br>&gt; &gt; &gt; &gt; &gt; &gt;<br>=
&gt; &gt; &gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; &gt; &gt; What is =C2=
=A0lowmem_reserve[]: 0 0 579 579 ?<br>&gt; &gt; &gt; &gt; &gt;<br>&gt; &gt;=
 &gt; &gt; &gt; This controls how much of memory from a lower zone you migh=
t an<br>&gt; &gt; &gt; &gt; &gt; allocation request for a higher zone consu=
me. E.g. __GFP_HIGHMEM is<br>&gt; &gt; &gt; &gt; &gt; allowed to use both l=
owmem and highmem zones. It is preferable to use<br>&gt; &gt; &gt; &gt; &gt=
; highmem zone because other requests are not allowed to use it.<br>&gt; &g=
t; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; &gt; Please see __zone_watermark_o=
k for more details.<br>&gt; &gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; &gt;=
<br>&gt; &gt; &gt; &gt; &gt; &gt; &gt; This is GFP_KERNEL request essential=
ly so there shouldn&#39;t be any lowmem<br>&gt; &gt; &gt; &gt; &gt; &gt; &g=
t; reserve here, no?<br>&gt; &gt; &gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt=
; &gt; &gt;<br>&gt; &gt; &gt; &gt; &gt; &gt; Why only low 1G is accessible =
by kernel in 32-bit system ?<br>&gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt;<=
br>&gt; &gt; &gt; &gt; 1G ivirtual or physical memory (I have 2GB of RAM) ?=
<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; virtual<br>&gt; &gt; &gt;<br>&gt; &gt;=
 =C2=A0I have set 2G/2G still it works ?<br>&gt;<br>&gt; It would reduce th=
e amount of memory that userspace might use. It may<br>&gt; work for your p=
articular case but the fundamental restriction is still<br>&gt; there<div><=
br><div><div>Thanks Michal..<br></div><div>&gt; --<br>&gt; Michal Hocko<br>=
&gt; SUSE Labs</div></div></div></div></div>

--000000000000b7a509058f7468f6--

