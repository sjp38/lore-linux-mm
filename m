Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65AD2C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:22:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22DA820B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:22:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OWGhjKZO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22DA820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9A9B6B0006; Mon,  6 May 2019 11:22:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B23386B0007; Mon,  6 May 2019 11:22:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C4B56B0008; Mon,  6 May 2019 11:22:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83BE76B0006
	for <linux-mm@kvack.org>; Mon,  6 May 2019 11:22:48 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id t12so10565094ioc.19
        for <linux-mm@kvack.org>; Mon, 06 May 2019 08:22:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GwjCs7waUjzCsD/Xg/lAVVPTMZTrnUgLhXYDBkanDSk=;
        b=pCWjF2nx2v6hOCSassXNjBBH54QOrDcDIsrlGtJwAKAf1mYrUJbfvKcHH21c1egCsv
         oRLD1Qh47YSuCPqdR4g8EJXzqP6H7rmADwlmYJWdbcGCoODUkB4O5f+6ouAVkhg1tEvP
         D6tKKDvqpe7k3Ct2Dg16w8boxgdBDXkUESzAXaCghcp272I4fzCwkrvI6GCYzKtoqOaa
         oFlehF3GQRIOmyHDnaBLSmriMGp7ClZe1I3nMS6cKAwhiKfKVBEbHQUCyJ8TH7t5XgDA
         4F/2gcArJvToAPbkdPKw0sFc2bVFUXKSqIHZ0DnJs0WqxLItJeYyMZ3JzopVYKd676ps
         VZ7g==
X-Gm-Message-State: APjAAAWcmQJkthwURQ6yFuGAmbeOgs4+6WKE7rwQx73JbkOpuIcww4S+
	B2iBsjQAMUKuxcdzsImPj013gRQ4v/MiIKgFnoZcl8pppbTBCJHMCBSYBEXV+DZFG329MMpDtQl
	luFyM/3oM+xEmDEUEzCGeMpLYl1L99MdtVf5KW29wjWHq4zXxYMJ0GxHg7cFjApLjyA==
X-Received: by 2002:a6b:6314:: with SMTP id p20mr16499946iog.229.1557156168315;
        Mon, 06 May 2019 08:22:48 -0700 (PDT)
X-Received: by 2002:a6b:6314:: with SMTP id p20mr16499911iog.229.1557156167819;
        Mon, 06 May 2019 08:22:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557156167; cv=none;
        d=google.com; s=arc-20160816;
        b=RZyqqK8aufFYf1jW+My0l+aPtWPwfKnYH2qYWyHVPFhGd+axwP0yKIo/dZ2sxmo3r7
         1wuBMXhQbnTciwn+/KZl8zo6+XAYpLe9Br7VKYFvCPPf/eTtEjNijQ3aSKjRFMvjhGge
         t5TAPpR1OqZFrLab72vQGR4hI8otroCg2BovYJr+Ud9E14BzvoJMxHEwlNMzmcNeQZWh
         A9WgRJ1fVawEKPMKJd2DcptiSGRhRDoJZHKh2epLm5QtdKnMkOBVTS9Uq3u6igNl0YTi
         rHXgoJewcEXHeWbOsqVi+7wBI3FHFWlSZcAKSfQMOzlvRZPxJ9hm220/I1UacJriIWhl
         XnXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GwjCs7waUjzCsD/Xg/lAVVPTMZTrnUgLhXYDBkanDSk=;
        b=fxTFYI7eDXotHLvi1WEkq+zQt+fCtm2SQSu48gubvhr9SIQukp6dn3zzzGQufqbmq0
         DXfEMpZ/ileHJL6M9XNVFtX8D4oox1Riqzy4AnvQtIkhiPuQbQUNpJ4RKnqvX+lsEYOT
         Ft8v9n7OlUKMF5HGGSoHwO0fv6Pe6gkhPl6QvVXLBfIhkSsaY3CERiIkQMZH1OZ+rT04
         kwbNuu+FdKEGj8KGdVFiCGpkjpBPVO8hSFvU88adOvVcl4QsHAC4JaskI5HQr43CUjV2
         RQfCGf2x8+JXCwU6rIGldC8B5LMmiXAStSUveBnwZO5Vm+PdKUV0VIgPQ0ZmXhDRZDD1
         6zDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OWGhjKZO;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor5433078iod.98.2019.05.06.08.22.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 08:22:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OWGhjKZO;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GwjCs7waUjzCsD/Xg/lAVVPTMZTrnUgLhXYDBkanDSk=;
        b=OWGhjKZOzYRCB0rqRJDqPrmz5F9AWSwawjP25Bbt/pucKURSLbTYhfD2a12A+pl5sD
         wDdqSpoqnH3Xweec7SSAAK2vouVxjpKsFzjgwpFKd4mb+hdArTQcB3VJ5Gwmp5wt0dZy
         rwQo/ZBUBAn3H384/vCbKuhUa9iU+yrSA97XCzeZsaYow88m1ZNg8Th0u9Pbhumk/XJ8
         x5kBXCaJo7IfXRbaOG/TT2UNt+6glsaFkhcJPCuBwwwgP7fC0FfBizVg7/+/5kSU+QBl
         h1Rq8Pg0qxfNLnye5FdPKDdbI9omyiZ+WECfpYenJMlp3cPdYhzhvA4nu29Gaz/xH9H8
         i2Pw==
X-Google-Smtp-Source: APXvYqzPlaPgkszSTGQfHRiI7VvMmDYTYeuVDMH6WOeUYuuNTH0sc8C0h78pwkJ5fWEzuDJx8adobhbfErCNeOONgdg=
X-Received: by 2002:a6b:6d06:: with SMTP id a6mr1998461iod.11.1557156167597;
 Mon, 06 May 2019 08:22:47 -0700 (PDT)
MIME-Version: 1.0
References: <1557038457-25924-1-git-send-email-laoar.shao@gmail.com> <20190506135954.GB31017@dhcp22.suse.cz>
In-Reply-To: <20190506135954.GB31017@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 6 May 2019 23:22:11 +0800
Message-ID: <CALOAHbAM26MTZ075OThmLtv+q_cCs_DDGVWW_GpycxWEDTydCA@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: avoid unnecessary PageTransHuge() when
 counting compound page
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 6, 2019 at 9:59 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Sun 05-05-19 14:40:57, Yafang Shao wrote:
> > If CONFIG_TRANSPARENT_HUGEPAGE is not set, hpage_nr_pages() is always 1;
> > if CONFIG_TRANSPARENT_HUGEPAGE is set, hpage_nr_pages() will
> > call PageTransHuge() to judge whether the page is compound page or not.
> > So we can use the result of hpage_nr_pages() to avoid uneccessary
> > PageTransHuge().
>
> The changelog doesn't describe motivation. Does this result in a better
> code/performance?
>

It is a better code, I think.
Regarding the performance, I don't think it is easy to measure.

Thanks
Yafang

