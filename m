Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2507AC3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 18:47:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D10FA2082F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 18:47:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tu/kYlLL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D10FA2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66B976B0352; Thu, 22 Aug 2019 14:47:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F4EE6B0353; Thu, 22 Aug 2019 14:47:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50B946B0354; Thu, 22 Aug 2019 14:47:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id 300E96B0352
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:47:33 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A8CC0180AD7C1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 18:47:32 +0000 (UTC)
X-FDA: 75850947144.20.pet75_5eec27282875b
X-HE-Tag: pet75_5eec27282875b
X-Filterd-Recvd-Size: 10314
Received: from mail-vs1-f65.google.com (mail-vs1-f65.google.com [209.85.217.65])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 18:47:32 +0000 (UTC)
Received: by mail-vs1-f65.google.com with SMTP id b20so4580908vso.1
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:47:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RQVB6FuC19N0aT5IdAg6G3ERLKxrmKxzffkSCzoWT4E=;
        b=tu/kYlLLZ/Ljk/Tz8IgFfWJ80mXGSGcCeM2+pels54Hh4z/kh6pWna2Xob/b9pPf8Z
         zabjgCB5peAKIz8r0T6xDNp/XMbkv6y48/YZYhMAj6uFmORozt25Jyoj2M28+t2AaD69
         jomRyWykR7hmcmx3MAr8Xw9dA60TMEpM3e31hTM12ajz0CKhaw1SCDWrYy+gYXynRSJ+
         Gva0fBdnnjPtU8TyO2I7l+KuMQgFTq40vip6b2ZKKTn4XYLhXjQYHBQZNBfbpX4b7YcL
         PAzT1+2XJVl9cSqoc6n9/MlPLv27lqeQwF4J9L19AxzskX+LUMn5czK5PVYEwL0mI17m
         UCmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=RQVB6FuC19N0aT5IdAg6G3ERLKxrmKxzffkSCzoWT4E=;
        b=dc3oVYQtC1RgPsa+1L7wGHPaIUnkbbAH2c/ipESYxM3fsXVdJtEBikbUlclcrunJ4m
         cICloHjoyH2fMQ2qGl/+7+8PcSUn/ubySCkTeuFT8B1CnA3a67KTdlxF035oophXmNAo
         b26dPYIwmdHX5cBx8ygWsu+2DJ5DGFVDuyoMG3BtdFAGjO7OVnLZ834kS7eAaCdufDVy
         cSp7OfuTr7054Eu1X5FqIdHiGJEL6OFbTC0aALe2ZlUo8ARygGmkLIARoyMcEdG6/ff+
         uf/OTAtmdxjv1boLirZ4LcpBSYPtTpQjt7HmmPz4cPnFx8hgR0AMgl9/JOAo2yxVNH7X
         2rFw==
X-Gm-Message-State: APjAAAXK5h61f/MfbmjS55eaKx7w1ZhBjWD2y7zmd69BfaOxpvOX6wuc
	pT7ZH0/N0eLmbc7nZDaC8mav0iGLaScesKIZ7dM=
X-Google-Smtp-Source: APXvYqyXZ0LLb1FNnzAgwUG4vWtqN1s9k/c/pIqbKmyg2chotlMjgZ3DVfyoL20jlu1Ewn3U/VQW7YnFekzW4Plsayc=
X-Received: by 2002:a67:e99a:: with SMTP id b26mr408475vso.106.1566499651543;
 Thu, 22 Aug 2019 11:47:31 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo56W1JGOc6w-NAf-hyWwJQ=vEDsAVAkO8MLLJBpQ0FTAcA@mail.gmail.com>
 <20190822130219.GK12785@dhcp22.suse.cz>
In-Reply-To: <20190822130219.GK12785@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Fri, 23 Aug 2019 00:17:22 +0530
Message-ID: <CACDBo57oFDEYY-GR1NEZEXKS409BkEx+RYywMNwuUn5f5Sz76A@mail.gmail.com>
Subject: Re: How cma allocation works ?
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Content-Type: multipart/alternative; boundary="0000000000004567850590b91f90"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000004567850590b91f90
Content-Type: text/plain; charset="UTF-8"

On Thu, Aug 22, 2019 at 6:32 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 21-08-19 22:58:03, Pankaj Suryawanshi wrote:
> > Hello,
> >
> > Hard time to understand cma allocation how differs from normal
allocation ?
>
> The buddy allocator which is built for order-N sized allocations and it
> is highly optimized because it used from really hot paths. The allocator
> also involves memory reclaim to get memory when there is none
> immediatelly available.
>
> CMA allocator operates on a pre reserved physical memory range(s) and
> focuses on allocating areas that require physically contigous memory of
> larger sizes. Very broadly speaking. LWN usually contains nice writeups
> for many kernel internals. E.g. quick googling pointed to
https://lwn.net/Articles/486301/
>
> > I know theoretically how cma works.
> >
> > 1. How it reserved the memory (start pfn to end pfn) ? what is bitmap_*
> > functions ?
>
> Not sure what you are asking here TBH
I know it reserved memory at boot time from start pfn to end pfn, but when
i am requesting memory from cma it has different bitmap_*() in cma_alloc()
what they are ?
because we pass pfn and pfn+count to alloc_contig_range and pfn is come
from bitmap_*() function.
lets say i have reserved 100MB cma memory at boot time (strart pfn to end
pfn) and i am requesting allocation of 30MB from cma area then what is pfn
passed to alloc_contig_range() it is same as start pfn or
different.(calucaled by bitmap_*()) ?
>
> > 2. How alloc_contig_range() works ? it isolate all the pages including
> > unevictable pages, what is the practical work flow ? all this works with
> > virtual pages or physical pages ?
>
> Yes it isolates a specific physical contiguous (pfn) range, tries to
> move any used memory within that range and make it available for the
> caller.
what i understood here is that it isolate pages between range as
MIGRATE_ISOLATE, removed pages from buddy allocator including
allocated(movable/unevictable) pages. how unevictable pages isolated here ?
>
> > 3.what start_isolate_page_range() does ?
>
> There is some documentation for that function. Which part is not clear?
>
mention in above question

> > 4. what alloc_contig_migrate_range does() ?
>
> Have you checked the code? It simply tries to reclaim and/or migrate
> pages off the pfn range.
>
What is difference between migration, isolation and reclamation of pages ?

> > 5.what isolate_migratepages_range(), reclaim_clean_pages_from_list(),
> >  migrate_pages() and shrink_page_list() is doing ?
>
> Again, have you checked the code/comments? What exactly is not clear?
>
Why again migrate_isolate_range() ?
(reclaim_clean_pages_fron_list) if we are reclaiming only clean pages then
pages will not contiguous ? we have only clean pages which are not
contiguous ?
What is work of shrink_page_list() ? please explain all flow with taking
one allocation for example let say reserved cma 100MB and then request
allocation of 30MB then how all the flow/function will work ?
> > Please let me know the flow with simple example.
>
> Look at alloc_gigantic_page which is using the contiguous allocator to
> get 1GB physically contiguous memory ranges to be used for hugetlb
> pages.
>
Thanks
> HTH
> --
> Michal Hocko
> SUSE Labs

--0000000000004567850590b91f90
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Thu, Aug 22, 2019 at 6:32 PM Michal Hocko &lt;<=
a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>&gt=
;<br>&gt; On Wed 21-08-19 22:58:03, Pankaj Suryawanshi wrote:<br>&gt; &gt; =
Hello,<br>&gt; &gt;<br>&gt; &gt; Hard time to understand cma allocation how=
 differs from normal allocation ?<br>&gt;<br>&gt; The buddy allocator which=
 is built for order-N sized allocations and it<br>&gt; is highly optimized =
because it used from really hot paths. The allocator<br>&gt; also involves =
memory reclaim to get memory when there is none<br>&gt; immediatelly availa=
ble.<br>&gt;<br>&gt; CMA allocator operates on a pre reserved physical memo=
ry range(s) and<br>&gt; focuses on allocating areas that require physically=
 contigous memory of<br>&gt; larger sizes. Very broadly speaking. LWN usual=
ly contains nice writeups<br>&gt; for many kernel internals. E.g. quick goo=
gling pointed to <a href=3D"https://lwn.net/Articles/486301/">https://lwn.n=
et/Articles/486301/</a><br>&gt;<br>&gt; &gt; I know theoretically how cma w=
orks.<br>&gt; &gt;<br>&gt; &gt; 1. How it reserved the memory (start pfn to=
 end pfn) ? what is bitmap_*<br>&gt; &gt; functions ?<br>&gt;<br>&gt; Not s=
ure what you are asking here TBH<div>I know it reserved memory at boot time=
 from start pfn to end pfn, but when i am requesting memory from cma it has=
 different bitmap_*() in cma_alloc() what they are ?=C2=A0</div><div>becaus=
e we pass pfn and pfn+count to alloc_contig_range and pfn is come from bitm=
ap_*() function.</div><div>lets say i have reserved 100MB cma memory at boo=
t time (strart pfn to end pfn) and i am requesting allocation of 30MB from =
cma area then what is pfn passed to alloc_contig_range() it is same as star=
t pfn or different.(calucaled by bitmap_*()) ?</div><div>&gt;<br>&gt; &gt; =
2. How alloc_contig_range() works ? it isolate all the pages including<br>&=
gt; &gt; unevictable pages, what is the practical work flow ? all this work=
s with<br>&gt; &gt; virtual pages or physical pages ?<br>&gt;<br>&gt; Yes i=
t isolates a specific physical contiguous (pfn) range, tries to<br>&gt; mov=
e any used memory within that range and make it available for the<br>&gt; c=
aller.</div><div>what i understood here is that it isolate pages between ra=
nge as MIGRATE_ISOLATE, removed pages from buddy allocator including alloca=
ted(movable/unevictable) pages. how unevictable pages isolated here ?<br>&g=
t;<br>&gt; &gt; 3.what start_isolate_page_range() does ?<br>&gt;<br>&gt; Th=
ere is some documentation for that function. Which part is not clear?<br>&g=
t;</div><div>mention in above question=C2=A0</div><div><br>&gt; &gt; 4. wha=
t alloc_contig_migrate_range does() ?<br>&gt;<br>&gt; Have you checked the =
code? It simply tries to reclaim and/or migrate<br>&gt; pages off the pfn r=
ange.<br>&gt;</div><div>What is difference between migration, isolation and=
 reclamation of pages ?</div><div><br>&gt; &gt; 5.what isolate_migratepages=
_range(), reclaim_clean_pages_from_list(),<br>&gt; &gt; =C2=A0migrate_pages=
() and shrink_page_list() is doing ?<br>&gt;</div><div>&gt; Again, have you=
 checked the code/comments? What exactly is not clear?<br>&gt;</div><div>Wh=
y again migrate_isolate_range() ?</div><div>(reclaim_clean_pages_fron_list)=
 if we are reclaiming only clean pages then pages will not contiguous ? we =
have only clean pages which are not contiguous ?</div><div>What is work of =
shrink_page_list() ? please explain all flow with taking one allocation for=
 example let say reserved cma 100MB and then request allocation of 30MB the=
n how all the flow/function will work ?<br>&gt; &gt; Please let me know the=
 flow with simple example.<br>&gt;<br>&gt; Look at alloc_gigantic_page whic=
h is using the contiguous allocator to<br>&gt; get 1GB physically contiguou=
s memory ranges to be used for hugetlb<br>&gt; pages.<br>&gt;</div><div>Tha=
nks<br>&gt; HTH<br>&gt; --<br>&gt; Michal Hocko<br>&gt; SUSE Labs</div></di=
v>

--0000000000004567850590b91f90--

