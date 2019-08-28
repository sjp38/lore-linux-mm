Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7B5EC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 18:53:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F4C2173E
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 18:53:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BA1KWLcF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F4C2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D8EF6B0006; Wed, 28 Aug 2019 14:53:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 189BE6B000C; Wed, 28 Aug 2019 14:53:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 079A06B000D; Wed, 28 Aug 2019 14:53:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id DB1166B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:53:51 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6C36782437D7
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:53:51 +0000 (UTC)
X-FDA: 75872735862.18.scarf68_3eb6a935e1d24
X-HE-Tag: scarf68_3eb6a935e1d24
X-Filterd-Recvd-Size: 5266
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com [209.85.221.65])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:53:50 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id t16so855876wra.6
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 11:53:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=dNeCU+ZF1utHP7CMktWuXnRZpMmmVHfRi6Kx10bzzBE=;
        b=BA1KWLcFdAWrtBsaDuNr8g3j/SgOrTjFpsCuTY0hNWE9awNEoFniam51IU2VODgqUe
         tWSuDD2MmJ6bGKNakIDXno5bS/OvPqmMHwa9fNrX1dfs9gE7XldIToxleEEzi/ehOzO0
         MKCJAk19lRJbqJCa0+kg7t0a6maVuWyju3oiJA6+iDQmvwhgEJJZycLHj9ayfRmCQ3KC
         neRbMBVmZagmm9I9yR/9bxQPZx2VJ2Uqvztc/ziKBS9h+fT4z/vSOu5QJUM2DVnqTr/Y
         MhJj/HDKmHd/d9T+c/olDopKTALXtdiye+EwbIOXaPXRxT4MDLc6wsFk7ksDReqiG183
         ebbA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=dNeCU+ZF1utHP7CMktWuXnRZpMmmVHfRi6Kx10bzzBE=;
        b=CV5RHNWEAILTXK2eJy/jC8ds6qnJAwkoeA0VgIU9bcyqIl9hmbefwpXLvxBX7YPdEz
         4991UVDQ9eiUG9qm52Bof+56Vpx52nUf8oPd0AmZjbmd5/SUqd3crMF0L95C31EdwJ+j
         hjVPLS0cXtiA29dILGvEX+58ablSTJdaAou8ee6dPak4Ke1BXSxJYvPET/9ImBRUdfFM
         3u2FW0W1gwzJFpGZu8d4ol6UNkIWYRgHAT/TDcZOT9rlxtzepmeL08seoVPR9rbXmnPj
         Ht+FNUh9qJrBnyw6ls+KMxrsieItMt9EEstTmvqIC+eFozMxlbCG/tpweXqAveXfSoFc
         RdbQ==
X-Gm-Message-State: APjAAAUDgxSP8QTlgqyKnfsQS/iwYfM8svYs3sTWcRbPG87+vjUGmub7
	W1fwCDFmyjb2Hf0AJ4X8U+J7l2wgujjiirImKko=
X-Google-Smtp-Source: APXvYqweyMAnZ6yIhLJf6sFauZxV8VlmGh+lO4k0uF5jXv7BE29ZuBpN3aPxry2ik8FodDnqX68+X+75s0hzK6URnCM=
X-Received: by 2002:adf:e286:: with SMTP id v6mr5946246wri.4.1567018429532;
 Wed, 28 Aug 2019 11:53:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org> <3e4eba58-7d24-f811-baa1-b6e88334e5a2@infradead.org>
In-Reply-To: <3e4eba58-7d24-f811-baa1-b6e88334e5a2@infradead.org>
From: Alex Deucher <alexdeucher@gmail.com>
Date: Wed, 28 Aug 2019 14:53:37 -0400
Message-ID: <CADnq5_PHNbSVUsM65sisfUwDxg_4-uEZWZMSQ=u78AWkaRdvtw@mail.gmail.com>
Subject: Re: mmotm 2019-08-27-20-39 uploaded (gpu/drm/amd/display/)
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Brown <broonie@kernel.org>, 
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Linux-Next Mailing List <linux-next@vger.kernel.org>, 
	Michal Hocko <mhocko@suse.cz>, mm-commits@vger.kernel.org, 
	Stephen Rothwell <sfr@canb.auug.org.au>, amd-gfx list <amd-gfx@lists.freedesktop.org>, 
	dri-devel <dri-devel@lists.freedesktop.org>, Harry Wentland <harry.wentland@amd.com>, 
	Leo Li <sunpeng.li@amd.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 2:51 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 8/27/19 8:40 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2019-08-27-20-39 has been uploaded to
> >
> >    http://www.ozlabs.org/~akpm/mmotm/
> >
> > mmotm-readme.txt says
> >
> > README for mm-of-the-moment:
> >
> > http://www.ozlabs.org/~akpm/mmotm/
> >
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> >
> > You will need quilt to apply these patches to the latest Linus release =
(5.x
> > or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated=
 in
> > http://ozlabs.org/~akpm/mmotm/series
> >
> > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss=
,
> > followed by the base kernel version against which this patch series is =
to
> > be applied.
> >
> > This tree is partially included in linux-next.  To see which patches ar=
e
> > included in linux-next, consult the `series' file.  Only the patches
> > within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included i=
n
> > linux-next.
>
> on i386:
>
> ../drivers/gpu/drm/amd/amdgpu/../display/dc/dcn20/dcn20_hwseq.c: In funct=
ion =E2=80=98dcn20_hw_sequencer_construct=E2=80=99:
> ../drivers/gpu/drm/amd/amdgpu/../display/dc/dcn20/dcn20_hwseq.c:2127:28: =
error: =E2=80=98dcn20_dsc_pg_control=E2=80=99 undeclared (first use in this=
 function); did you mean =E2=80=98dcn20_dpp_pg_control=E2=80=99?
>   dc->hwss.dsc_pg_control =3D dcn20_dsc_pg_control;
>                             ^~~~~~~~~~~~~~~~~~~~
>                             dcn20_dpp_pg_control
>
>
> Full randconfig file is attached.

Fixed here:
https://cgit.freedesktop.org/~agd5f/linux/commit/?h=3Ddrm-next&id=3Dda26ded=
3b2fff646d28559004195abe353bce49b

Alex

>
> --
> ~Randy
> _______________________________________________
> amd-gfx mailing list
> amd-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/amd-gfx

