Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E8A9C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 17:05:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92DE820850
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 17:05:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="neFWsyTg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92DE820850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2E2A6B05C3; Mon, 26 Aug 2019 13:05:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDF326B05C5; Mon, 26 Aug 2019 13:05:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF49F6B05C6; Mon, 26 Aug 2019 13:05:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id B72F16B05C3
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:05:17 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6B5B352C1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 17:05:17 +0000 (UTC)
X-FDA: 75865204674.03.snow11_11004aece761a
X-HE-Tag: snow11_11004aece761a
X-Filterd-Recvd-Size: 9124
Received: from mail-vs1-f68.google.com (mail-vs1-f68.google.com [209.85.217.68])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 17:05:16 +0000 (UTC)
Received: by mail-vs1-f68.google.com with SMTP id 62so11453376vsl.5
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:05:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=X2/chHEAv7RZ+Y4cGhowSGvUuLae4iBZ86eEce4YdbI=;
        b=neFWsyTgT1C3IgNqiP2xQaiwBjK5T1OZe6AUTkpBunWEmCqhat3t16VhNLi6HEAniS
         Qfw6HZ/Kx0heFzZ7zY1ojhDSqODG/p2BFY+PNYiF0/4dBjyypLaKSOmHoazlsldNjx7E
         wj3mq+i3m6KBzkD0Jaf4wTcHeovs2fT+VtA5rpVb2HtZfLGGRuqWEUgR9H041aLdxGPA
         j1rbbh2WkZxOFRBWhWaUOSI/itcbOYCEMMN5U0wX1Yyng/ZyC9lhdC3iRC4XsEBuF/hf
         Z81PgC3f07K6W4z6AKzWwdoJ28Cn8ZbTDZWB+IpkZ7/mErXc+LUbbHd43uknK2tofa6U
         2rag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=X2/chHEAv7RZ+Y4cGhowSGvUuLae4iBZ86eEce4YdbI=;
        b=O3O9O3Bx2Xr+PTB1oNk1Em5ZZ1+I4Iqesp1/MY2XWUfVSd03ySEYiII1IxgUCf3MoN
         hfciTMQsgdB7u4TwfkE9YJhJV2dK5uLvl+jQVuT874BSmQrbi1ueOCdeyBUhmBDMuTyx
         BC9L6AoGSmekQWtdxYzrKqgEWOni9XDq5rR7QP1Zj/Azpn5XyeGAQiXMwVnJnkR230UY
         pibxaEFWdNv8QMLxwrWNPdXjeh3kqJ0DTNLZAVrlR98GDlPXv1DecB131S4jhu4p7/ZA
         taL5adv7RPC/KMQs9A3WP5zgOfIbMwvdEdrdn15BJtwU51bwCURAm1HIEoyY1jypHjnd
         AbfQ==
X-Gm-Message-State: APjAAAU+X9Bmc6mpqagaLBVAL9pdj/CCdKOt+Fs52pV0KGBAXRo87uMW
	5sv/2zDw44zvs1khPYpsemS9883wJKANcFMXSdw=
X-Google-Smtp-Source: APXvYqz3S2jAbk8g7/3p/+QeXAuO/O6twLh/ExGKnXpfzfFOT9cJeBCDWAmJ0tFK3zb9GKqzVfOzGmrqsDuP6Ioj6gk=
X-Received: by 2002:a67:e45a:: with SMTP id n26mr10739573vsm.94.1566839115866;
 Mon, 26 Aug 2019 10:05:15 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo57u+sgordDvFpTzJ=U4mT8uVz7ZovJ3qSZQCrhdYQTw0A@mail.gmail.com>
 <20190822125231.GJ12785@dhcp22.suse.cz> <CACDBo57OkND1LCokPLfyR09+oRTbA6+GAPc90xAEF6AM_LmbyQ@mail.gmail.com>
 <20190826070436.GA7538@dhcp22.suse.cz>
In-Reply-To: <20190826070436.GA7538@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Mon, 26 Aug 2019 22:35:08 +0530
Message-ID: <CACDBo555_pxZjixThUZcqnADVVcmH1Qtfrr5H-2AR12L0=Rx3A@mail.gmail.com>
Subject: Re: PageBlocks and Migrate Types
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Content-Type: multipart/alternative; boundary="000000000000ebe5370591082801"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000ebe5370591082801
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 26, 2019 at 12:34 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 22-08-19 23:54:19, Pankaj Suryawanshi wrote:
> > On Thu, Aug 22, 2019 at 6:22 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Wed 21-08-19 22:23:44, Pankaj Suryawanshi wrote:
> > > > Hello,
> > > >
> > > > 1. What are Pageblocks and migrate types(MIGRATE_CMA) in Linux
memory ?
> > >
> > > Pageblocks are a simple grouping of physically contiguous pages with
> > > common set of flags. I haven't checked closely recently so I might
> > > misremember but my recollection is that only the migrate type is
stored
> > > there. Normally we would store that information into page flags but
> > > there is not enough room there.
> > >
> > > MIGRATE_CMA represent pages allocated for the CMA allocator. There are
> > > other migrate types denoting unmovable/movable allocations or pages
that
> > > are isolated from the page allocator.
> > >
> > > Very broadly speaking, the migrate type groups pages with similar
> > > movability properties to reduce fragmentation that compaction cannot
> > > do anything about because there are objects of different properti
> > > around. Please note that pageblock might contain objects of a
different
> > > migrate type in some cases (e.g. low on memory).
> > >
> > > Have a look at gfpflags_to_migratetype and how the gfp mask is
converted
> > > to a migratetype for the allocation. Also follow different
MIGRATE_$TYPE
> > > to see how it is used in the code.
> > >
> > > > How many movable/unmovable pages are defined by default?
> > >
> > > There is nothing like that. It depends on how many objects of a
specific
> > > type are allocated.
> >
> >
> > It means that it started creating pageblocks after allocation of
> > different objects, but from which block it allocate initially when
> > there is nothing like pageblocks ? (when memory subsystem up)
>
> Pageblocks are just a way to group physically contiguous pages. They
> just exist along with the physically contiguous memory. The migrate type
> for most of the memory is set to MIGRATE_MOVABLE. Portion of the memory
> might be reserved by CMA then that memory has MIGRATE_CMA. Following
> set_pageblock_migratetype call paths will give you a good picture.

it means if i have 4096 continuous pages = 1 pageblock
then all the 4096 pages of same type. but if any one page is different than
block type then ? it changed the block type or something else ?
>
>
> > Pageblocks and its type dynamically changes ?
>
> Yes as the purpose of the underlying memory for the block changes.
okay
>
> --
> Michal Hocko
> SUSE Labs

--000000000000ebe5370591082801
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Mon, Aug 26, 2019 at 12:34 PM Michal Hocko &lt;=
<a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>&g=
t;<br>&gt; On Thu 22-08-19 23:54:19, Pankaj Suryawanshi wrote:<br>&gt; &gt;=
 On Thu, Aug 22, 2019 at 6:22 PM Michal Hocko &lt;<a href=3D"mailto:mhocko@=
kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>&gt; &gt; &gt;<br>&gt; &gt;=
 &gt; On Wed 21-08-19 22:23:44, Pankaj Suryawanshi wrote:<br>&gt; &gt; &gt;=
 &gt; Hello,<br>&gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; 1. What are Page=
blocks and migrate types(MIGRATE_CMA) in Linux memory ?<br>&gt; &gt; &gt;<b=
r>&gt; &gt; &gt; Pageblocks are a simple grouping of physically contiguous =
pages with<br>&gt; &gt; &gt; common set of flags. I haven&#39;t checked clo=
sely recently so I might<br>&gt; &gt; &gt; misremember but my recollection =
is that only the migrate type is stored<br>&gt; &gt; &gt; there. Normally w=
e would store that information into page flags but<br>&gt; &gt; &gt; there =
is not enough room there.<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; MIGRATE_CMA r=
epresent pages allocated for the CMA allocator. There are<br>&gt; &gt; &gt;=
 other migrate types denoting unmovable/movable allocations or pages that<b=
r>&gt; &gt; &gt; are isolated from the page allocator.<br>&gt; &gt; &gt;<br=
>&gt; &gt; &gt; Very broadly speaking, the migrate type groups pages with s=
imilar<br>&gt; &gt; &gt; movability properties to reduce fragmentation that=
 compaction cannot<br>&gt; &gt; &gt; do anything about because there are ob=
jects of different properti<br>&gt; &gt; &gt; around. Please note that page=
block might contain objects of a different<br>&gt; &gt; &gt; migrate type i=
n some cases (e.g. low on memory).<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; Have=
 a look at gfpflags_to_migratetype and how the gfp mask is converted<br>&gt=
; &gt; &gt; to a migratetype for the allocation. Also follow different MIGR=
ATE_$TYPE<br>&gt; &gt; &gt; to see how it is used in the code.<br>&gt; &gt;=
 &gt;<br>&gt; &gt; &gt; &gt; How many movable/unmovable pages are defined b=
y default?<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; There is nothing like that. =
It depends on how many objects of a specific<br>&gt; &gt; &gt; type are all=
ocated.<br>&gt; &gt;<br>&gt; &gt;<br>&gt; &gt; It means that it started cre=
ating pageblocks after allocation of<br>&gt; &gt; different objects, but fr=
om which block it allocate initially when<br>&gt; &gt; there is nothing lik=
e pageblocks ? (when memory subsystem up)<br>&gt;<br>&gt; Pageblocks are ju=
st a way to group physically contiguous pages. They<br>&gt; just exist alon=
g with the physically contiguous memory. The migrate type<br>&gt; for most =
of the memory is set to MIGRATE_MOVABLE. Portion of the memory<br>&gt; migh=
t be reserved by CMA then that memory has MIGRATE_CMA. Following<br>&gt; se=
t_pageblock_migratetype call paths will give you a good picture.<div><br>it=
 means if i have 4096 continuous pages =3D 1 pageblock<br>then all the 4096=
 pages of same type. but if any one page is different than block type then =
? it changed the block type or something else ?=C2=A0<br>&gt;<br>&gt;<br>&g=
t; &gt; Pageblocks and its type dynamically changes ?<br>&gt;<br>&gt; Yes a=
s the purpose of the underlying memory for the block changes.<br>okay <br>&=
gt;<br>&gt; --<br>&gt; Michal Hocko<br>&gt; SUSE Labs</div></div>

--000000000000ebe5370591082801--

