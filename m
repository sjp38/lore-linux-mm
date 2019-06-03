Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31ACCC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF08527AC0
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xRY+ChZw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF08527AC0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7231F6B000D; Mon,  3 Jun 2019 10:35:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ACA36B0266; Mon,  3 Jun 2019 10:35:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59DAE6B0269; Mon,  3 Jun 2019 10:35:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 206416B000D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:35:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o12so11881214pll.17
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:35:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sguE7ubsOXMXCXkJwdzmP68NZ8elMAcGv1SEYKB2XP4=;
        b=VUZkczo0r/lwRJhPHDqss3xTJYYIGzHB/N0zbrdXVK6p6LShzngZLEZkOrLH7mse3T
         BW2iq9w+FI/htbZxVBCxZXU0WRjUmf1ZM9vuV9pMjZfQ4dPn/lALeIbHdDgYQTzFQt+M
         ebudpySfISd4oIdKDzMnFNIPHVAPO27c/Da1gSt/pB8Wtt9fWHs6C6FVB8cVrz5Ky5Cv
         kDiycjniYopvc+y2v06E07ga+OgNlOV5IxOjW0K7qy1qZy0TMTx5BJh3ddDLpDHRiFQJ
         n3zI9QQyvseqe30OhHEeXWvJy/Ht/ddshr1JP6tyxiGNToUK3FGwlg3bjRwpdN79rlRw
         AlQQ==
X-Gm-Message-State: APjAAAUU0Is13q1YCSKv0fFCIWhixMD0K5mVX95ZQz1rYLsk8te45B7R
	gsuXEbcFLUvDsBiscNKmwJ4hJwHP5S9gbOPSBp/CtUlnEc524j0iXwVtgVdvW1zf7d8wUDIT5w6
	srpsYm6zXmFK3IJzrniEPpLu3VDvWzgM+5RcSnoSZZzLl3DwN26DohYkZNJvFtEUthQ==
X-Received: by 2002:a17:902:14e:: with SMTP id 72mr31100633plb.36.1559572536747;
        Mon, 03 Jun 2019 07:35:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtMevA5pk6ISi7bVUyW7bP72iucmBJaoiXjc8+qzv2XEptWCfsNFkFJL3bW2XJ4U2tw8M4
X-Received: by 2002:a17:902:14e:: with SMTP id 72mr31100567plb.36.1559572536131;
        Mon, 03 Jun 2019 07:35:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572536; cv=none;
        d=google.com; s=arc-20160816;
        b=ax85qj88KebdvWC0cKYfGdMBANU22Rrzbt6bOKRKm62V7hp2B5QKAEJkdrz8SqzgNj
         lDwUfiDoMIdOG6nQB2fboYeflsa8uPiKJeA1C8FA6Zz2nNvJoWlbEsvnmlqvIFwINDFc
         2AKdZdyehHFjnYLFJdFVezDHDUC/ISW/0z0hiQeAdC88z46PQ9Dy0pglF+xd1AJCg+Ys
         KOMiqmAQNZytkgkqvceWmFZRdiqOy4+WubOYGte3tuI/nyBIZzN7AXTd8x4+TMqS3RoE
         8lcorsw/ftaszEcFcVQKlCPcZQgdbr74Upauif51bgQiF8sPAAkTSEMjQA58BeHhL4jg
         8ZZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sguE7ubsOXMXCXkJwdzmP68NZ8elMAcGv1SEYKB2XP4=;
        b=PPVCd2Gh++uROkzPu1GyevKVE2b9yolM8vwuqxwiPoeaioWhuVExsazrawklx8ys+q
         SwklsYObrwGAIc3tnMBqj/qQ9U856A84lKwySkBdAEZYmr6FtDOT+IkCRy+95XYcBdyJ
         E+9y+agkD3vXvc9JsKjMl0EoRyTsYZHYAE8ne1oF9zMXYUa3rJKnDaKz2Z0hZ4RR6Oy/
         RkDKAANfuApGuUw6TphVGV9hDS6dAfG5X/bJQal3w/EaGDpl0WtalJUl+xnKVSdugxjo
         tisji2W5EU5uKg0rqGYzXlqAnVfEpUth+f6WQb0ndvNwt0O6pGKHTuUE9fuBvkkSMZHY
         NDCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xRY+ChZw;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t12si3950119plr.151.2019.06.03.07.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:35:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xRY+ChZw;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com [209.85.167.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7CCD727AC0
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 14:35:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559572535;
	bh=hk/xMLxFXk4kJBGBwlcG++wGkbLPTKk2rGWiw3Ye9mQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=xRY+ChZwcxFTR01zBWEpCDzqDawzaXX8BoxQ0hmqSrh2c+43cmgeskejeZ2bdG25X
	 vRPjSFEyjtGBkNKFUbEn3pOB1Ubc6IkL+wNksi7gfju4OwJjpwhSuOFaCRWfP5229N
	 ZPfaGKPgvA6q8jvaV/hupBv4lNEgmua37PINB+R0=
Received: by mail-lf1-f50.google.com with SMTP id d7so4253688lfb.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:35:35 -0700 (PDT)
X-Received: by 2002:ac2:4891:: with SMTP id x17mr2053137lfc.60.1559572533667;
 Mon, 03 Jun 2019 07:35:33 -0700 (PDT)
MIME-Version: 1.0
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
 <20190603135939.e2mb7vkxp64qairr@pc636> <CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
 <20190604003153.76f33dd2@canb.auug.org.au>
In-Reply-To: <20190604003153.76f33dd2@canb.auug.org.au>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Mon, 3 Jun 2019 16:35:22 +0200
X-Gmail-Original-Message-ID: <CAJKOXPed=npnfk0H2WUDityHg5cPLH_zwShyRd+B2RS8h6C7SQ@mail.gmail.com>
Message-ID: <CAJKOXPed=npnfk0H2WUDityHg5cPLH_zwShyRd+B2RS8h6C7SQ@mail.gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Uladzislau Rezki <urezki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Marek Szyprowski <m.szyprowski@samsung.com>, 
	"linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, linux-kernel@vger.kernel.org, 
	Hillf Danton <hdanton@sina.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, 
	Andrei Vagin <avagin@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jun 2019 at 16:32, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Krzysztof,
>
> On Mon, 3 Jun 2019 16:10:40 +0200 Krzysztof Kozlowski <krzk@kernel.org> wrote:
> >
> > Indeed it looks like effect of merge conflict resolution or applying.
> > When I look at MMOTS, it is the same as yours:
> > http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=b77b8cce67f246109f9d87417a32cd38f0398f2f
> >
> > However in linux-next it is different.
> >
> > Stephen, any thoughts?
>
> Have you had a look at today's linux-next?  It looks correct in
> there.  Andrew updated his patch series over the weekend.

Yes, I am looking at today's next. Both the source code and the commit
728e0fbf263e3ed359c10cb13623390564102881 have wrong "if (merged)" (put
in wrong hunk).

Best regards,
Krzysztof

