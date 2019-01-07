Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FF8EC43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 08:38:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29D71206B7
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 08:38:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EswmIADM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29D71206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 701158E000C; Mon,  7 Jan 2019 03:38:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 687BF8E0001; Mon,  7 Jan 2019 03:38:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54FE58E000C; Mon,  7 Jan 2019 03:38:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2790B8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 03:38:07 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 135so25332itk.5
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 00:38:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CVx1N3/1yZKes91LPFLzCoAaNamYHEmbi9lrJ9mdkOM=;
        b=SUaEiTmvBZcHOUILEgOkWTOql2h7dPDToPCil7DU3YgcUh/d4XQmUOMtoedLsGZf2x
         DFevCrOAzWEmDeS5QdoddWhtjdugkxIZx7g49cPcnm34O/mwngtQBCGcGct5M7X9IZRk
         ZGTXRbadEsEtje1xmtGRFBiWi2iuyFScvaG7jn9SfUztRhPPevtcHBb8x5AgM0m0y15n
         yBY9o6e6SCnfRgniULad/SSlX/e46oaLUbf9Z6B0soXKePGRKdv7QkdUssZDOiZq8FIi
         fKxYO6jgWXD/+hH+5Iy8Tp9Bk2bVrEC5UzpeAYsLZIwkRFhcOz+3IcCYjAxu9wJJRmaz
         AX4Q==
X-Gm-Message-State: AJcUukdeeuEWQRU7E8F3P2k4ZHclAdG+43iFiMKtoxVc481RuCiUgWvn
	dA9v3RJAkkAIKehtw+6HShBHqKJVFGcQ1jyoIp7ldVMSyJwdgmu9aa0yMyf+uyzpdTg+Pdpxf3H
	wkubWzgxVcULNM7+CNaANPvMZj8ogOGdgADpPCUpBksegnMSvrq/ngxUmon0UqyMXPg+HGJ93Z3
	6hoDJc1/uQSMEuvlwWCUDbmg+uOp+ytnLHJszffILRrtqyls2Jfwbdkk6C27VYdl9s5M+U/x67W
	CODMl4uXFbVNVydZ9n/4knBtFnl7XVnqufRHu5dqro4Dy/niuwOhigwKfloN5wf4ZMF6EHjDfeL
	7ychKxqkUk/fE3Op5oy+ABgPGz3fjmuyIJ0GCVRbXc9JRZsedT5e3IF7ztPhixmFAiWLv4fFRyX
	M
X-Received: by 2002:a24:65c8:: with SMTP id u191mr6900633itb.7.1546850286769;
        Mon, 07 Jan 2019 00:38:06 -0800 (PST)
X-Received: by 2002:a24:65c8:: with SMTP id u191mr6900613itb.7.1546850286038;
        Mon, 07 Jan 2019 00:38:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546850286; cv=none;
        d=google.com; s=arc-20160816;
        b=BoE0GM3uJf6ERLFYwDtMUDziDQYO8juTzRQzyWakBPq+cill8+1gHfN+GWEq2dwVGT
         6SvwwzRrjURPglI1Lx/993tLn6ubiSI1ZdTp9C0/nnI54avNWSi/V93GkiSu1H4L231d
         WOrPmxX8y4h/2COUZSGh4m8Ws0zs1QQhr1mQ2VIiywQtlFALidZLovoI0nmdML3tj5aY
         1P8WRljgkTrc23fmEJsncSddeJfBJoDS9ZZRJQ06jEoBObKp4kvt5r+dE/RWw5zMM3kH
         xGMu/5u0nIk4WgVnrMHl7r2bz6k0fmFP+MUBEetf/+3uym0MRPvy9oT8PDXW5Q3qc/uM
         iTOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CVx1N3/1yZKes91LPFLzCoAaNamYHEmbi9lrJ9mdkOM=;
        b=bAT+TE2LJyXV/6IKXQFYNzkWbajYC0QL7F2yHLNrlNyxnT344hlegwj8jeMkRzawFR
         mTxPSbbv4s+80IsVKid0PmkhV2xpkUOZxYaIF0Iezbq7py0VFm7gsFHRa8+zqOGjlxgn
         Mh0Kh5DtGOIchc5hAJcPjTkpBpxjmt1CcTUxau8Uh+iQ3fEghxyuaqcStugGdH38RCk3
         GGnwD+xdfJiWs8F1sjDNnzEvtAlRX4iKLKspjJCeBP6OTJGYoC+QdPEbzhmqrpiLHk1x
         HZAyi5mU14tZG7pjS0KCSfXdPIRpOtVW84MxAlVxzjjeo7DbRCQfKmc/S2GRPo/1Uh5W
         5Kyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EswmIADM;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l125sor32115426iof.41.2019.01.07.00.38.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 00:38:06 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EswmIADM;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CVx1N3/1yZKes91LPFLzCoAaNamYHEmbi9lrJ9mdkOM=;
        b=EswmIADMoit8HAC/ONWLIUOs82xUyZZ7KMpmO9np6klXABsQU1QTRU18JTuiNxSRAO
         JqCEQgIK+qEXqqFcT232liEa7b5BoboTP1JaHua26Oxa3PU6ycJYqOje/YOsiHvTN8hu
         h72X/T2z8V4h4XkHJOprue2txZdkbRWgcW91+MtWEN19h2y984vSFt7LlQpQ8mSXiAZ0
         yFG3AunNP1aSP7HEefVBgpijQe27ZzmdODIBmHYBeyWeG5+vk3VBUqgd44hSWiEWf900
         HTYM6PegdJmyslG9PeWQE8bjwKTPXGS5giqesuBuGi+5zHfrIQ+1VE8C/UWcQXqXW2Za
         WaiA==
X-Google-Smtp-Source: ALg8bN565vD9gCVSgZ0kouTj2emPGiwItjw1PmyzR2yMpnUaBIORex/wGD7CZ9/km0XWTaveGh3JDkr1kJL25ChZtV0=
X-Received: by 2002:a6b:3f06:: with SMTP id m6mr39444084ioa.117.1546850285729;
 Mon, 07 Jan 2019 00:38:05 -0800 (PST)
MIME-Version: 1.0
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-2-git-send-email-kernelfans@gmail.com> <20181231084018.GA28478@rapoport-lnx>
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
 <20190102092749.GA22664@rapoport-lnx> <20190102101804.GD1990@MiWiFi-R3L-srv>
 <20190102170537.GA3591@rapoport-lnx> <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
In-Reply-To: <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 7 Jan 2019 16:37:54 +0800
Message-ID:
 <CAFgQCTt2=6mwFid8HS+K5UsqkBv8y7N5WOoKpVxYzNxjwmV75A@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of bottom-up
 after parsing hotplug attr
To: Tejun Heo <tj@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>, linux-acpi@vger.kernel.org, 
	linux-mm@kvack.org, kexec@lists.infradead.org, 
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, 
	Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, 
	yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107083754.xCTXqk_T4YyKmXaUNGeM1JmfU5J7ptgTswVvgC9Lp50@z>

I send out a series [RFC PATCH 0/4] x86_64/mm: remove bottom-up
allocation style by pushing forward the parsing of mem hotplug info (
https://lore.kernel.org/lkml/1546849485-27933-1-git-send-email-kernelfans@gmail.com/T/#t).
Please give comment if you are interested.

Thanks,
Pingfan

On Fri, Jan 4, 2019 at 2:47 AM Tejun Heo <tj@kernel.org> wrote:
>
> Hello,
>
> On Wed, Jan 02, 2019 at 07:05:38PM +0200, Mike Rapoport wrote:
> > I agree that currently the bottom-up allocation after the kernel text has
> > issues with KASLR. But this issues are not necessarily related to the
> > memory hotplug. Even with a single memory node, a bottom-up allocation will
> > fail if KASLR would put the kernel near the end of node0.
> >
> > What I am trying to understand is whether there is a fundamental reason to
> > prevent allocations from [0, kernel_start)?
> >
> > Maybe Tejun can recall why he suggested to start bottom-up allocations from
> > kernel_end.
>
> That's from 79442ed189ac ("mm/memblock.c: introduce bottom-up
> allocation mode").  I wasn't involved in that patch, so no idea why
> the restrictions were added, but FWIW it doesn't seem necessary to me.
>
> Thanks.
>
> --
> tejun

