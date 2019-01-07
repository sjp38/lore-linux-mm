Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06E7AC43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF4D42173C
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="YBtIrEuP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF4D42173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49CAA8E002C; Mon,  7 Jan 2019 09:39:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 449F98E0001; Mon,  7 Jan 2019 09:39:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 312E28E002C; Mon,  7 Jan 2019 09:39:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id D080F8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:22 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b186so149957wmc.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MgR59jfi1kQ8zgjSThadf+p9+kl1MDrvdK55shLEZYA=;
        b=Y/wVlQAJviZwc3VKyHB+zH5Fci7P6899D7BsGDjYzJqigG3W4FKnC9z5yXK0aFMVUy
         vxiHzbGxY3Eu/OZKionAYt23biBp6RXYOZYW420wS8hjdxBK1AxsX5T6hde/SosrGXCc
         Npt92OCS7v2NCYNjIp8UQQnOvBSdzTVhYfrIiPipbYu5g4ergd+kZmP2376CXSmkw7Z+
         HnqfkgjTBJpA2JzahML3yfxz/dFru1h4y6366/WTvBYUAwgDpt/ggrNZB8EdlXtDvyKJ
         JApsKXbeG4G7SxTmpTm2gGldc09VpLQEMFl3nnvwNROA5WMVQwUI+YP5XrE9+bUarok4
         wbzQ==
X-Gm-Message-State: AJcUukexGqmqSXHl3xsXLg9YVUsbMxkpMXCnEjD1NsOv8aDMsEmSXrOe
	LM0MUbxunvozNzzptzh1u8QK48rB3wD5vtzoltD5TAEDxpPjRNUqYajkuPmcOQnEccZJkntlfN3
	9rHWZJRBOgPAJAq8/+3yWe8Y/OGBC6AWAGLFDZo8L1EX84bFNmCh266wZwXbO8QhcJ54P+8aYIF
	TGlpPWll7MWyTZQepxYcULkECK7DohK0MY2GJvtkIGP46WnpfDDj3i0FzQD50gRKoqn7mUeSuLz
	w3bTMjH1tUEsG/gwyKwfvBLO4qJ0CwKWx2KqQIRWiXhucqLITQ3+yMVb/kix9VW09E2YsVs1QhH
	ik3p0l1iboqR2VVwTlrPXVUxpOGlo4jgkNK4ajArDeIBLhAXyPlVAXD/fYxm6uC6ofr9POKCyhO
	e
X-Received: by 2002:a5d:56d2:: with SMTP id m18mr55644738wrw.113.1546871962367;
        Mon, 07 Jan 2019 06:39:22 -0800 (PST)
X-Received: by 2002:a5d:56d2:: with SMTP id m18mr55644696wrw.113.1546871961537;
        Mon, 07 Jan 2019 06:39:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546871961; cv=none;
        d=google.com; s=arc-20160816;
        b=lm4MgC5WwfV3HHDIB0IdYsWALRTNR2/gRM9l4tuxzlp4YvGP1mLWlsg885cubUlWSD
         CQxmGPG4B2wv8UkQcTo+TJdDWXFX7+x/f+Loj8S5vnlO9RYSpLs6KtwqE/5oUzfsEMIj
         OBjnn7slCdBCu4Eu3zjSC2eHyrf55cpeDmgBW29I3a3qkncQYb/beNs+5QSKgx3Dl01y
         uFRmY75LuIjvPgfFdZzgf0EylFMxz+4j8wcBBEJgF71xXwjvG0pf+Aw2iRZPPhCLzrLL
         V/Qt2dko53fDZiCkApXxruXHgBbr1/o7IL76MslE1gLA0BOPXTnLc7HapGb1hzkE7jgV
         DTkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MgR59jfi1kQ8zgjSThadf+p9+kl1MDrvdK55shLEZYA=;
        b=OBQMC3cO2x0hnea6WPto7faIjYaDq2ZvJSy3C02M6xjV0kVwQ1Pt/NEpTkrSRLLD9f
         7eUIQBzJhvVjn/ZXDbFetUNevDKKCLN0BEBLzzoGj9JN8/RFJdC4RhhNnclFKBCqp4bQ
         7QjzkrETHLVGaRElxES5BgFsVMOqHs56VzzncliKx5DPktnncrBerLMnPqWLP3eVztUO
         anSg3eB6G/+MhyRnf6ugpWoLTadGPOGubc/CuK3Jy1pp+VZ68TdCmudsH6n8jyeShMQs
         JjSsrW0TDAvdIdRFo86ayRU7K63uIXmSutOFpgL66gEw5wwP5cvmiMo5SHxwKRO+XI+6
         oHBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=YBtIrEuP;
       spf=pass (google.com: domain of amit.pundir@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=amit.pundir@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1sor35185705wro.44.2019.01.07.06.39.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:21 -0800 (PST)
Received-SPF: pass (google.com: domain of amit.pundir@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=YBtIrEuP;
       spf=pass (google.com: domain of amit.pundir@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=amit.pundir@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MgR59jfi1kQ8zgjSThadf+p9+kl1MDrvdK55shLEZYA=;
        b=YBtIrEuPiKng0sd+zTQrbimV25ScTF6JHUDSlmvS2oUzDO78mLx0Mb/o1MdJWQMZHy
         v50iwxE4mBJ6CGtzOstZw4x+Efh+NYUePOi0AyD70/I+Mn3/izo+VPYzFLotY4gP5iut
         7Vh9aCkhe/MbW6MYBdBByIQJF7DRUSowKMyXU=
X-Google-Smtp-Source: ALg8bN4sBT5lQsmfevBEriKosOerKoklx3shvUXRG1D1AY2lff6FjyJrBfuIPunndXBgg4Hunm0bgAbkyan7lXglPZM=
X-Received: by 2002:adf:e983:: with SMTP id h3mr50281784wrm.232.1546871961064;
 Mon, 07 Jan 2019 06:39:21 -0800 (PST)
MIME-Version: 1.0
References: <CAMi1Hd0fZwp7WzGhLSmWG3K+DS+nwT9P9o=zAOGRFDDhjpnGpQ@mail.gmail.com>
 <20190107114710.GA206194@google.com>
In-Reply-To: <20190107114710.GA206194@google.com>
From: Amit Pundir <amit.pundir@linaro.org>
Date: Mon, 7 Jan 2019 20:08:44 +0530
Message-ID:
 <CAMi1Hd2Zo=zK-rYUd9=Fq87QU7qr2rhftJB+CS-OUFWFQD+OPQ@mail.gmail.com>
Subject: Re: [for-4.9.y] Patch series "use up highorder free pages before OOM"
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, 
	Mel Gorman <mgorman@techsingularity.net>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107143844.1E6cVwyGc2lr8SwSvxBWEGgm5VuY-aybYOPCJqhT9po@z>

On Mon, 7 Jan 2019 at 17:17, Minchan Kim <minchan@kernel.org> wrote:
>
> On Mon, Jan 07, 2019 at 04:37:37PM +0530, Amit Pundir wrote:
> > Hi Minchan,
> >
> > Kindly review your following mm/OOM upstream fixes for stable 4.9.y.
> >
> > 88ed365ea227 ("mm: don't steal highatomic pageblock")
> > 04c8716f7b00 ("mm: try to exhaust highatomic reserve before the OOM")
> > 29fac03bef72 ("mm: make unreserve highatomic functions reliable")
> >
> > One of the patch from this series:
> > 4855e4a7f29d ("mm: prevent double decrease of nr_reserved_highatomic")
> > has already been picked up for 4.9.y.
> >
> > The original patch series https://lkml.org/lkml/2016/10/12/77 was sort
> > of NACked for stable https://lkml.org/lkml/2016/10/12/655 because no
> > one else reported this OOM behavior on lkml. And the only reason I'm
> > bringing this up again, for stable-4.9.y tree, is that msm-4.9 Android
> > trees cherry-picked this whole series as is for their production devices.
> >
> > Are there any concerns around this series, in case I submit it to
> > stable mailing list for v4.9.y?
>
> Actually, it was not NAK. Other MM guy wanted to backport but I didn't
> intentionally because I didn't see other reports at that time.
>
> However, after that, I got a private email from some other kernel team
> and debugged together. It hit this problem and solved by above patches
> so they backported it.
> If you say Android already check-picked them, it's third time I heard
> the problem(If they really pick those patch due to some problem) since
> we merge those patches into upstream.
> So, I belive it's worth to merge if someone could volunteer.

This is where it gets tricky, Code Aurora cherry-picked these patches
for their Android v4.9.y tree, where they get applied cleanly i.e. no
backport needed. But there is no way to tell if these patches indeed
solved an OOM bug or two for them.

So let me put it this way, is it safe to apply this series on v4.9
kernel? Or should I be wary of regressions?

Regards,
Amit Pundir

>
> Thanks.

