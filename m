Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B214CC43218
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 20:08:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 652B72064A
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 20:08:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HXdALYq6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 652B72064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 044106B0003; Sun, 28 Apr 2019 16:08:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F35986B0006; Sun, 28 Apr 2019 16:08:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E24DA6B0007; Sun, 28 Apr 2019 16:08:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1ACE6B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 16:08:18 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k20so2739788qtk.13
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 13:08:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+TG+gf49pEHpK22EE9Rak4ugReFKQZlKT164LJBhbAA=;
        b=XJRH/pQ+qYHSKpeCwsW0zJbUnHW2AnMZyvvuiuJRi/3E8aDWpkI9IKgOIV4wMjXuiW
         XMEpsTrjC5R1u6C1R5wioSGONbiYahNsR+uH3rzc5orYYRiUoX47VtVvSh6RFXTUk27I
         2iE2A2Fqoht7LZfTqfBme42z5DAIiNenqXPCxGi71G8fjsnVIZQ+RSY7dQwyFw3V0hso
         4gLTcRVEwc2MLGKJK+TMbvrlOa8OVGeRjPJU8rtmg8xMl+x866DAo/K3LC3ZU9MRlk92
         5ysPwf+zxFfVdoOQWh2w4GBJTT6aM8xrUvLAjkvgdSB5ctYJWsHX5zmtAEgLDmVi3jfZ
         VICQ==
X-Gm-Message-State: APjAAAUiVL5fNVuq2EBmgXMNW2pW2k/6FHlYwhvCATdj43ceE2qF88qv
	FCRsjUpLVlkraJyZj7H9eKCKzV6y4V4PZ3B3cczgCOEHpkoZ7Fl4C40cHPtNHcMbEA2rGxxvZvQ
	9DfFCte7xN6413N7wj4kswcIme0ghyQjO3sV4Kxkjf3JQiBTmYdQDgT//RwrP6mh8Uw==
X-Received: by 2002:a0c:f990:: with SMTP id t16mr21803371qvn.54.1556482098570;
        Sun, 28 Apr 2019 13:08:18 -0700 (PDT)
X-Received: by 2002:a0c:f990:: with SMTP id t16mr21803318qvn.54.1556482097667;
        Sun, 28 Apr 2019 13:08:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556482097; cv=none;
        d=google.com; s=arc-20160816;
        b=y02HNYInW02m+ATVT/Drb7hga3u7VP0wfsQl/1zSY6gQEGOeFAjR/+3vlzZ8QUzUZl
         Cfv+jHDxcLsEAKL6ZZjMaHAovEj4wHrZa2GhMpEv/dVte2SlEUY7ihx0+J4moKQgvwUj
         Dudz7DbbOz8HZR5D8qqGyj1XNm79c/EZi1H7XywpUxN8+GVDoFIfOC0AaHwY2kHsBzcn
         uYCCTKKJtGT7seraMhuJ2q8a4LsFuCEo5D7RGDw+0zUsJYpeQucALUPLFqFMeUxhrYAU
         9h6VO8qTykyste4TfScnMS99U/KG+Nl2s4gZ+MnAck7vcNNj5mhGvaNkA1+Abo+DoMd1
         lvgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+TG+gf49pEHpK22EE9Rak4ugReFKQZlKT164LJBhbAA=;
        b=VZG+CRvvDx89QjLEP9jAFUBlSUEBSQvE3cjnJ+3XlGtv+uvs9kLAy7rSALnGa59nBJ
         7G9/iLVfxDOOqNTW/TwVoajlGmKURMEV+bCS+S/+PcZXWnsXDrHTXFi9o4SXKBchtud1
         WSL8cm+8WQN5n6fmioUeIBK3jcCr8RY644c50FMKvpI2x49FjEywsStvFlYQHjs2fQpy
         6nQe+d6BVXwNeK9dlj1jrt33anjyh5c2gIc4sqP+xDTXfVq4G8Qg9z4t1zeL0fvIATmY
         J+fKHtf/4aC1y0AbvRAINvhnUOITaL9D0C9eafGPd94TiEutuoQjBiOZ+Os7VqzcqOlU
         xKEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HXdALYq6;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h6sor19005731qkc.52.2019.04.28.13.08.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Apr 2019 13:08:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HXdALYq6;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+TG+gf49pEHpK22EE9Rak4ugReFKQZlKT164LJBhbAA=;
        b=HXdALYq6b9r7GsIAIxnkX7onjXgh+ntIQ2eZUekOKApjWokpRazNDapRCnlqZjZlba
         yJD7p1MBS4SsCA6NWLP7mg0IyuJgqNVspkCbLpevZnCcAihNrvKlXUurLtZ/B84BfV0j
         ygFriMsFr00eZs5WfweBEuf0Fh0uoulN5eEWjIbpQkc3whqwxBs+6F0OPLqFQdhld/6T
         0eJX5WpgFHfiaq4Yw0Ty7Ju/KNhvkgQkxZvjhnQaA111Whs7HoRHVTd3bS81W28v/Qu4
         PUYDWz915NRuT5GNVM/7MBCQR7fO73gtCoRiNpiXVCBWCxvC2ZJ+xXv+Kk+8V/UL5NJg
         gJuQ==
X-Google-Smtp-Source: APXvYqyY7Guy4fBnDVm0U135CZZ8DQ/qbPJpUyjw6gfqVUE2LstKp6DuoxXJnPCzdYOSsMtv9O5W+ybjrRUw5Odz5I8=
X-Received: by 2002:a37:64cf:: with SMTP id y198mr32380276qkb.5.1556482097417;
 Sun, 28 Apr 2019 13:08:17 -0700 (PDT)
MIME-Version: 1.0
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220134454.GF12668@bombadil.infradead.org> <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
 <20190220144345.GG12668@bombadil.infradead.org> <20190220163921.GA4451@localhost.localdomain>
 <20190220171905.GJ12668@bombadil.infradead.org> <B53C9F2D-966C-4DFD-8151-0A7255ACA9AD@oracle.com>
In-Reply-To: <B53C9F2D-966C-4DFD-8151-0A7255ACA9AD@oracle.com>
From: Song Liu <liu.song.a23@gmail.com>
Date: Sun, 28 Apr 2019 13:08:05 -0700
Message-ID: <CAPhsuW6uDeXrRU9pd-kPOzjJn3DVdx0O5Lny_hpyQ=Fpbhg4gw@mail.gmail.com>
Subject: Re: Read-only Mapping of Program Text using Large THP Pages
To: William Kucharski <william.kucharski@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, Keith Busch <keith.busch@intel.com>, 
	Linux-MM <linux-mm@kvack.org>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, 
	linux-nvme@lists.infradead.org, linux-block@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi William,

On Mon, Apr 8, 2019 at 4:37 AM William Kucharski
<william.kucharski@oracle.com> wrote:
>
>
>
> > On Feb 20, 2019, at 10:19 AM, Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Yes, on reflection, NVMe is probably an example where we'd want to send
> > three commands (one for the critical page, one for the part before and one
> > for the part after); it has low per-command overhead so it should be fine.
> >
> > Thinking about William's example of a 1GB page, with a x4 link running
> > at 8Gbps, a 1GB transfer would take approximately a quarter of a second.
> > If we do end up wanting to support 1GB pages, I think we'll want that
> > low-priority queue support ... and to qualify drives which actually have
> > the ability to handle multiple commands in parallel.
>
> I just got my denial for LSF/MM, so I was hopeful someone who will
> be attending can talk to the filesystem folks in an effort to determine what
> the best approach may be going forward for filling a PMD sized page to satisfy
> a page fault.
>
> The two obvious solutions are to either read the full content of the PMD
> sized page before the fault can be satisfied, or as Matthew suggested
> perhaps satisfy the fault temporarily with a single PAGESIZE page and use a
> readahead to populate the other 511 pages. The next page fault would then
> be satisfied by replacing the PAGESIZE page already mapped with a mapping for
> the full PMD page.
>
> The latter approach seems like it could be a performance win at the sake of some
> complexity. However, with the advent of faster storage arrays and more SSD, let
> alone NVMe, just reading the full contents of a PMD sized page may ultimately be
> the cleanest way to go as slow physical media becomes less of a concern in the
> future.
>
> Thanks in advance to anyone who wants to take this issue up.

We will bring this proposal up in THP discussions. Would you like to share more
thoughts on pros and cons of the two solutions? Or in other words, do you have
strong reasons to dislike either of them?

Thanks,
Song

