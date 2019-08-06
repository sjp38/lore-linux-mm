Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB20C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:09:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30B652089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:09:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g6GT+Z4P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30B652089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C27B46B0006; Tue,  6 Aug 2019 11:09:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD8626B0007; Tue,  6 Aug 2019 11:09:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC6786B0008; Tue,  6 Aug 2019 11:09:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 849F46B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:09:32 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id v20so22026070vsi.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=eDwsFonqVZxDM6gNAA+dS2YEbbScC1VCDQsI3+gkMJk=;
        b=FP7/utAZWmV6cIDV92xsF28ltAXtF3l5ugFJDq80+Otml02j9As7h2DExNMpK3X6Hq
         a4kY8tfQ9MmdVvVnkhx/4rYMabLNeTaeN7UiREzwGZExUzMGeyrt/9ptl/UqNpLlOn5Y
         zoY8A46kh4XwkHMg97BaOqovTh52ResEP1XnMsa0TQDo3siKodVlFWd9XxLO+DxCj9Pt
         o/6UGb+k/DlgtLwBm7MsIKOjWr50WaOg994KiUAY1NY+2hUAULeovRObHP6/Qvl4VmeD
         50iNGt+Q46mL/rm6ZK/5fBi4te302lbrpI9XUg+T8gD+l6iUBSYlAog9jAM0nk2KUVl0
         GGig==
X-Gm-Message-State: APjAAAWxmJ9fxsQJGmWIPeMZ7jvfuGsISnAW/z5EojhmxBiIljtq4Afa
	D4LKvn3Jd6mkhoKQGttjLjxYNRIzYJWkRMkJVHBlYhiH25xcISYkDAItythpbMEDk5+aqKRzL5I
	LtXb7n9VDagoCsHmv8Aif/OktyjluJPw37KmA0W0WCsiQT7Tp7aL38GCY0hGWjsWo9A==
X-Received: by 2002:a67:ad06:: with SMTP id t6mr2706155vsl.44.1565104172283;
        Tue, 06 Aug 2019 08:09:32 -0700 (PDT)
X-Received: by 2002:a67:ad06:: with SMTP id t6mr2706089vsl.44.1565104171571;
        Tue, 06 Aug 2019 08:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565104171; cv=none;
        d=google.com; s=arc-20160816;
        b=qkvrXNWcrKLc0OszUfYK499w5oZgrVfLEl7ymR9Ll0gmqVSOz7g5RJ6rXCSq2eyUml
         hJsmx9cg7kFQZhlUcAzL8u33hJXM/CBhuIBkt1UZadyxnvltl2kwHIpWyw5wUL3quHuH
         L8iFsQPDnrfy3fXu+8263sRdWRNZdcVYwyn6sKfs9OPT9uEXSjqi2eU0E19R+4jOa3Yu
         QGRA4HZEREjL+ewZIoobx6ZEvmiKfpviMQpDV++y4LVptE6Nguc1+IQ9hEM7Y04diyNP
         3iSR+IsxmvY+GlIeMsSySYgNRv29aBUDczk60YCTCJ0ALlgrhfx4xB2nFNfsuBzVLChd
         67UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=eDwsFonqVZxDM6gNAA+dS2YEbbScC1VCDQsI3+gkMJk=;
        b=ijTC4YqEHTmQ8RAFSK+YxRJA5N9fRiCTMzXlPivvWmm7W0lTANHGTisF/inabo0rMF
         /QguMZjcCtdMSGY7DCWMQvT6ZPpXDRtpxYayin3Kr5zzfNi35jp+yWxRA4dTPxVyrRU3
         g2jUQqmXnIWlXcWpKk+8A8KY97crxYabqMGlTRxxex0PyIIlDwA4wuUrjqAV1U3oSbng
         bY4oIboYGiuD55/WTMF9N7bxDj8t3xCoQ78k0d1687nBb2Xa3X6TyODL/kpIG92FTioU
         e44a8T2nH1Q3vIZySzDQDP6YwGST2c8EKBtxIpVNbkGpp8ogChxnd3OhWzJP0g//0bj7
         9Leg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=g6GT+Z4P;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 92sor41978072uah.73.2019.08.06.08.09.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 08:09:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=g6GT+Z4P;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=eDwsFonqVZxDM6gNAA+dS2YEbbScC1VCDQsI3+gkMJk=;
        b=g6GT+Z4PkvK9k4j4vpZxSUHVQSjwsJTAS/oiJ/NbnVkC93Q/uFmqW2+Vc530kRTiep
         2sbrZAuuKsd6BG0o1Ph32+xF3edcW8zCTGl+gAFFLI4XrFjEH1DD7zucyyOZconmtsRf
         bqRmh7o9B+4Gp+NLxbgWinRTY5BzMSjZBAqJ0Z5jkxSd3v5KP6GsZ27WXVPQOgHdkenh
         19GdacSMiP8UmUKU/G5Kkooni1D4Rm2ysZQ3zD+bO1S5bRLbggBBhfmc3olZWS0u6hek
         qDppqlhBBuxTNU+b91fXFJNYYHU49cDDk7HfPeAG0sJJ5WIHtrH9vwpujn8nqghgT7XA
         htaA==
X-Google-Smtp-Source: APXvYqwhWwWKYgEM6sp9crBfjzjJPbES2BV3b+Kylsw6IhjRdVaaGDRqh+jXf6BvyLWWXW/eWJckTqIOUDQOBQSWi78=
X-Received: by 2002:ab0:30a4:: with SMTP id b4mr2616266uam.134.1565104171092;
 Tue, 06 Aug 2019 08:09:31 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz> <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz> <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
 <20190805201650.GT7597@dhcp22.suse.cz> <CACDBo54kBy_YBcXBzs1dOxQRg+TKFQox_aqqtB2dvL+mmusDVg@mail.gmail.com>
 <20190806150733.GH11812@dhcp22.suse.cz>
In-Reply-To: <20190806150733.GH11812@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Tue, 6 Aug 2019 20:39:22 +0530
Message-ID: <CACDBo54KihsV=8NLGZkTghTzb2p70WURF2L5op=fW7DGj_vJ1A@mail.gmail.com>
Subject: Re: oom-killer
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	pankaj.suryawanshi@einfochips.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 8:37 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 20:24:03, Pankaj Suryawanshi wrote:
> > On Tue, 6 Aug, 2019, 1:46 AM Michal Hocko, <mhocko@kernel.org> wrote:
> > >
> > > On Mon 05-08-19 21:04:53, Pankaj Suryawanshi wrote:
> > > > On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wro=
te:
> > > > >
> > > > > On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> > > > > > On 8/5/19 1:24 PM, Michal Hocko wrote:
> > > > > > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P =
          O  4.14.65 #606
> > > > > > > [...]
> > > > > > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af=
24>] (out_of_memory+0x140/0x368)
> > > > > > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121=
e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> > > > > > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>=
]  (__alloc_pages_nodemask+0x1178/0x124c)
> > > > > > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001=
155
> > > > > > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<=
c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> > > > > > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c144=
7e08 r6:c1216588 r5:00808111
> > > > > > >> [  728.079587]  r4:d1063c00
> > > > > > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c02=
20470>] (_do_fork+0xd0/0x464)
> > > > > > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:0000=
0000 r6:c1216588 r5:d2d58ac0
> > > > > > >> [  728.097857]  r4:00808111
> > > > > > >
> > > > > > > The call trace tells that this is a fork (of a usermodhlper b=
ut that is
> > > > > > > not all that important.
> > > > > > > [...]
> > > > > > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high=
:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_fi=
le:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB =
mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB=
 local_pcp:0kB free_cma:0kB
> > > > > > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > > > > > >
> > > > > > > So this is the only usable zone and you are close to the min =
watermark
> > > > > > > which means that your system is under a serious memory pressu=
re but not
> > > > > > > yet under OOM for order-0 request. The situation is not great=
 though
> > > > > >
> > > > > > Looking at lowmem_reserve above, wonder if 579 applies here? Wh=
at does
> > > > > > /proc/zoneinfo say?
> > > >
> > > >
> > > > What is  lowmem_reserve[]: 0 0 579 579 ?
> > >
> > > This controls how much of memory from a lower zone you might an
> > > allocation request for a higher zone consume. E.g. __GFP_HIGHMEM is
> > > allowed to use both lowmem and highmem zones. It is preferable to use
> > > highmem zone because other requests are not allowed to use it.
> > >
> > > Please see __zone_watermark_ok for more details.
> > >
> > >
> > > > > This is GFP_KERNEL request essentially so there shouldn't be any =
lowmem
> > > > > reserve here, no?
> > > >
> > > >
> > > > Why only low 1G is accessible by kernel in 32-bit system ?
> >
> >
> > 1G ivirtual or physical memory (I have 2GB of RAM) ?
>
> virtual
>
 I have set 2G/2G still it works ?

>
> > > https://www.kernel.org/doc/gorman/, https://lwn.net/Articles/75174/
> > > and many more articles. In very short, the 32b virtual address space
> > > is quite small and it has to cover both the users space and the
> > > kernel. That is why we do split it into 3G reserved for userspace and=
 1G
> > > for kernel. Kernel can only access its 1G portion directly everything
> > > else has to be mapped explicitly (e.g. while data is copied).
> > > Thanks Michal.
> >
> >
> > >
> > > > My system configuration is :-
> > > > 3G/1G - vmsplit
> > > > vmalloc =3D 480M (I think vmalloc size will set your highmem ?)
> > >
> > > No, vmalloc is part of the 1GB kernel adress space.
> >
> > I read in one article , vmalloc end is fixed if you increase vmalloc
> > size it decrease highmem. ?
> > Total =3D lowmem + (vmalloc + high mem)
>
> As the kernel is using vmalloc area _directly_ then it has to be a part
> of the kernel address space - thus reducing the lowmem.
> --
> Michal Hocko
> SUSE Labs

