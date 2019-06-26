Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C5D9C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:40:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D432321670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:40:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Cbc//tN1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D432321670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 567236B0003; Wed, 26 Jun 2019 19:40:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5171A8E0003; Wed, 26 Jun 2019 19:40:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 405BC8E0002; Wed, 26 Jun 2019 19:40:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6D286B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 19:40:55 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e8so218912wrw.15
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 16:40:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=20lhFHwi567YcDUXje66ZZdTOwufs21R8Ro6+UMNHqw=;
        b=s2Ns56b0mgwSIXP6KDQqFlCHpW2Ko056o8nGqloDHzYhOs70P1lDl8/ladC3R81qXO
         UDySuGZNBYRPxXOywxGotqgTxkQ09nGz5EOs2LcsPJc+L++C+weLxwxrr9eEjLP8k/s2
         Jj/qkwrdXlc8240CALedYzRITypsBwt2vSo88rrHL/fIKqnOMZ96zRUo6eH2yfNrc/NE
         dbnmGJSQ0S62cjgVU6Tr+ie/0zWXemu4w9yjYmyChdDM7eruq/CPKJt7lziRB8g7yLlf
         /oCQUXUWrNtjIpwoENgKKW5WuFF+a/RgQdaILTT9xaKkDxuzUwytWy+gm4TcZ5Iugo7m
         /kEA==
X-Gm-Message-State: APjAAAUqQvTENyNJHyEIhxpr1FuYrJ6JGp4U3cTqAApnQA28OKkadYCg
	EOK6eZ3DgVorJLloLVsxt2+8niEik1hFxSmXyjY5wKD6kcTuYYtrkqmxZCBduPwaGF5s4ZIhaBO
	babDRgTe/aH11DvlRl09BDufvaFC0gOJDaIg54YHXjtO1YZ/ZTD5fI8oQc7yqpvpalA==
X-Received: by 2002:a5d:5702:: with SMTP id a2mr261518wrv.89.1561592455516;
        Wed, 26 Jun 2019 16:40:55 -0700 (PDT)
X-Received: by 2002:a5d:5702:: with SMTP id a2mr261493wrv.89.1561592454846;
        Wed, 26 Jun 2019 16:40:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561592454; cv=none;
        d=google.com; s=arc-20160816;
        b=oh9zsXpum7S7JMvVrMi4claqCXDeLNM9fQggoYMss2U17x6VzLxBopoLp7A8RZo5Wv
         7n3Pni45VQuJiF2QwYVGVgIzww2swPW//j/WB4BskQQM3NZrB9AEVZFcBiB5lXgMB79U
         aTCurTpdcCFbvLVfs005I0Eza6Bu2z1q/1DmJ1yuU+D3zZdxm85dux0wI14+yzJy6Khf
         BjUcR5dw6f7XXTUcs/6aFL+YPK9xf5HbOHx4Mupm68wE2cR3CUW9EzoqoGeJ+vmmOuyt
         eQDPFrWcfGgx/rsxXMH6WumVvPYD4wyWYnA00FeTW9bSzwVJPlClAl0EF3OmyZO4gXRo
         v8ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=20lhFHwi567YcDUXje66ZZdTOwufs21R8Ro6+UMNHqw=;
        b=KzbYdWPATZXAS4zrmZV5jeaYKfvb8eP9uBkCgSZ9wA91DI7txuPZIRm41xO4IGgna/
         dRa5VZogH+NjtU9iMMRiv4mJIHkiymiMiGVBXVoK8WSUgZsUIplD7PQCN+e/WmR6BX89
         hlBuETzGb5AZn07QE8Z+0vYtaNHM2iEdmn0/LW7aLMePPuYbX3/AizMPn5kdYFReXNVL
         XIa14A0e4Nv8a7KwJomzS5L9ajEX6DuE+CcujxFVaemsvFGP+XsrsuEUGl7KmdTK/rZV
         p6XRK/lN5sjFeYWK9cY3USQMekFvQ9tcZn+E6W9VwF86RYDLaubdQT8YuaHOndC5NJGt
         HYaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Cbc//tN1";
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor271629wra.32.2019.06.26.16.40.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 16:40:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Cbc//tN1";
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=20lhFHwi567YcDUXje66ZZdTOwufs21R8Ro6+UMNHqw=;
        b=Cbc//tN1TeEFCOvsoWHFQ4BTpLO+LTWWzgefQZksS9ZLSaczjKhevQAoo0eE9tpFv9
         aaBLYv+vMpODmAwp6I7hV/dwi3pC8PyxQ9uAlj+Fe7tmD3Qxp/sRQ4apxi1UEeJKK5ea
         OrOq2WyfO3jxmAP2wlJ3H+2Zhi9YnJ5n5mtBY=
X-Google-Smtp-Source: APXvYqy1aIv/OnOwSZokpJGQdzynZZKeWgHN1iOxJbCWxys7/eVCl7XYstjOH1Z+ooOvscpx+qxCjqe4kpOYI1PbP/Q=
X-Received: by 2002:a5d:4909:: with SMTP id x9mr229836wrq.226.1561592453903;
 Wed, 26 Jun 2019 16:40:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190626180429.174569-1-semenzato@chromium.org> <20190626151947.9876bb0ed8b2953813bfa5c6@linux-foundation.org>
In-Reply-To: <20190626151947.9876bb0ed8b2953813bfa5c6@linux-foundation.org>
From: Luigi Semenzato <semenzato@chromium.org>
Date: Wed, 26 Jun 2019 16:40:41 -0700
Message-ID: <CAA25o9RJb9EJxJTHWqWjkOr+h+FrtowpfB4+_mEY7TUrUXHuNQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: smaps: split PSS into components
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Yu Zhao <yuzhao@chromium.org>, bgeffon@chromium.org, 
	Sonny Rao <sonnyrao@chromium.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 3:19 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 26 Jun 2019 11:04:29 -0700 semenzato@chromium.org wrote:
>
> > From: Luigi Semenzato <semenzato@chromium.org>
> >
> > Report separate components (anon, file, and shmem)
> > for PSS in smaps_rollup.
> >
> > This helps understand and tune the memory manager behavior
> > in consumer devices, particularly mobile devices.  Many of
> > them (e.g. chromebooks and Android-based devices) use zram
> > for anon memory, and perform disk reads for discarded file
> > pages.  The difference in latency is large (e.g. reading
> > a single page from SSD is 30 times slower than decompressing
> > a zram page on one popular device), thus it is useful to know
> > how much of the PSS is anon vs. file.
> >
> > This patch also removes a small code duplication in smaps_account,
> > which would have gotten worse otherwise.
> >
> > Also added missing entry for smaps_rollup in
> > Documentation/filesystems/proc.txt.
> >
> > ...
> >
> > -static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
> > +static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
> > +     bool rollup_mode)
> >  {
> >       SEQ_PUT_DEC("Rss:            ", mss->resident);
> >       SEQ_PUT_DEC(" kB\nPss:            ", mss->pss >> PSS_SHIFT);
> > +     if (rollup_mode) {
> > +             /*
> > +              * These are meaningful only for smaps_rollup, otherwise two of
> > +              * them are zero, and the other one is the same as Pss.
> > +              */
> > +             SEQ_PUT_DEC(" kB\nPss_Anon:       ",
> > +                     mss->pss_anon >> PSS_SHIFT);
> > +             SEQ_PUT_DEC(" kB\nPss_File:       ",
> > +                     mss->pss_file >> PSS_SHIFT);
> > +             SEQ_PUT_DEC(" kB\nPss_Shmem:      ",
> > +                     mss->pss_shmem >> PSS_SHIFT);
> > +     }
>
> Documentation/filesystems/proc.txt is rather incomplete.  It documents
> /proc/PID/smaps (seems to be out of date) but doesn't describe the
> fields in smaps_rollup.
>
> Please update Documentation/ABI/testing/procfs-smaps_rollup and please
> check that it's up-to-date while you're in there.
>

Thank you for noticing the stale/missing docs and sorry that I did not.
Will email the updated patch shortly.

