Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47A79C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E10C3218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:02:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DH0vdrW5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E10C3218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D0346B0003; Thu, 21 Mar 2019 19:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7801B6B0006; Thu, 21 Mar 2019 19:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 646376B0007; Thu, 21 Mar 2019 19:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44B086B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 19:02:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so511220qtz.14
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:02:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=jr0o9aAH8U2i6K1qdS9XGG6vuPudU722Wp+0qgcH1UY=;
        b=pr7hVfxlFnosaMquAXvMaH1RsIdUozp/3KTHtDpoxAXDXL43iwKpUEzdJZvUtvQSMb
         qqFvSBV5uygdEln/dzWGKJIHhQdejCBS242IQX3HOj3oUtlcS1MeKr048Gl9kFgpHjU0
         hclpEdXhIcLadXT7jODjgjK+K5tXsHQkmmhJeXwyc19t1VG6GCMFJpibR+zDFCnkBCvT
         5n2uUmZmk16L7A4KaH/WgPKLWZGn0Wc6gLImRRBb8ZmJ+p1qgiW/57LMYptTyRt9mMYA
         5Fjj4SOpt8Fm8o47QsRrSkKa9WWr9YocM10GtuTSti3PTW8rl4raUEZ21whHK+VsYmRj
         9wDw==
X-Gm-Message-State: APjAAAV6Fd0HO6A4mRaG8XKwE0xT2olfnW+HdOzZ7fl+xX2X61Fp4m7U
	ufyo9WA1NfciF0GhTcfcVv2UQXHeXn8sOx0Qw/7uUWmSXCQwDD6GxmYJYPqbqYXZu02jfIhA5iR
	yvj4iLncb8XZRYHUFMFZGZIy/99frQ2blzlEUdfx9JRM1XiZBQ2fX1sItROr3uF+MPw==
X-Received: by 2002:a37:69c3:: with SMTP id e186mr1372499qkc.308.1553209340990;
        Thu, 21 Mar 2019 16:02:20 -0700 (PDT)
X-Received: by 2002:a37:69c3:: with SMTP id e186mr1372427qkc.308.1553209340060;
        Thu, 21 Mar 2019 16:02:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553209340; cv=none;
        d=google.com; s=arc-20160816;
        b=SkMSA+BMjdwb9E34tihs2/8k90qhZPoqq32mBEBvDQMtAGlCz+j2AriZNueBehe4xw
         g5v/KU9TUNJCSVo9HbeSceLG7lUhLtBn7QQ5NtzJWOf8MHrebdAjMZfUueI5uNuh0UbT
         7qwG5alkt2r4zZ7Md+eJI94bovtIIIx/2tMZdl64VIZ0Qi8vOIKt6uYaJeRNzNxdm6mj
         hVGAyi6Dz9XTkYUZHRVuwyCtKTfUrYauFkGIxU/jo7RbukUPMUVuMzwmcP+awHbsgc+o
         wu3ZHjL+h1Rymv8XCs1j+gS88Oo4wYaJna3NV2bhTY61/A5oMmXorJcxYOkbI6i3PyYC
         aOrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=jr0o9aAH8U2i6K1qdS9XGG6vuPudU722Wp+0qgcH1UY=;
        b=x8akw+83V1lfjuMPP791CmItIehoXBtGqvScU6+wkNqjttLoZL4ox+A1uOaXBSJAbZ
         YNyVRmSqdcR4PPIe8SM7suHJ64C6//De5ZGd5TPYklt64aW6YsWu4GrXP9EtkdWLzha8
         dpwyPUUPprJtuffpBMeYT69P7CGxJRFVnrjqehZYUGLb0Uf0iungAqXjtV+QbJZ4q0Fy
         EZMmEeAmy9DSFlwpE4TUE2TceeqF9iUv0MknWS/nQR36L7NhuLPN/POgDtoLK8Ursl/X
         IZHe6fjE//vy/BbFDOXChsZkWMX1lRBvD9EdT9K3n0U/Hd263INudLgqkL268c+qXfpm
         gBjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DH0vdrW5;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p36sor7359736qvc.71.2019.03.21.16.02.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 16:02:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DH0vdrW5;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=jr0o9aAH8U2i6K1qdS9XGG6vuPudU722Wp+0qgcH1UY=;
        b=DH0vdrW5HrWLC2m5DWcl3u7lzhGbcHNbP5YBsYeIODLg2teReTwDMbqQrWQthtoDKc
         XtyNGw98Bbu0m0uKzfH/bJAd7ONWR/ITjtyU3P5v7Lscw3cyGdhNQgIKrPe25WDzTmYj
         IehzBxhSRxRtSwVAZYasYBxbHn5VjtWXuUVR6S8SwxxtnBqEDplp30k4y4vAPfktIpC6
         8Iypy3RyHoF5soUPEx6P6iVi1iy1YdQjJO3em1xqQo0pk9QkNQ/Vt3tSWv3eMm6exLWv
         c+4Q4Fwcv1qIqinza5RcQ6/3Cfocpm/n37fjEQSicvvMLSY/q2R0Sb+9jq2c6e/gMf9c
         IlrQ==
X-Google-Smtp-Source: APXvYqxHxi89Srq1zwUqJV8b9yrJ78B4HghLbO4qcrhP/PA7s1rCJ8Lw7BQMe1FVovIdbxt6bxn1cWSIq7iH0hV7Bjg=
X-Received: by 2002:a0c:ea4f:: with SMTP id u15mr5454069qvp.133.1553209339794;
 Thu, 21 Mar 2019 16:02:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190321200157.29678-1-keith.busch@intel.com> <5B5EFBC2-2979-4B9F-A43A-1A14F16ACCE1@nvidia.com>
 <20190321223706.GA29817@localhost.localdomain>
In-Reply-To: <20190321223706.GA29817@localhost.localdomain>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 21 Mar 2019 16:02:07 -0700
Message-ID: <CAHbLzkrLyG-j8kRrrQ==4Y4LDDLubvXMF88muyzXWAQWKw1ZSw@mail.gmail.com>
Subject: Re: [PATCH 0/5] Page demotion for memory reclaim
To: Keith Busch <keith.busch@intel.com>
Cc: Zi Yan <ziy@nvidia.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, 
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>, 
	David Nellans <dnellans@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 3:36 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Thu, Mar 21, 2019 at 02:20:51PM -0700, Zi Yan wrote:
> > 1. The name of =E2=80=9Cpage demotion=E2=80=9D seems confusing to me, s=
ince I thought it was about large pages
> > demote to small pages as opposite to promoting small pages to THPs. Am =
I the only
> > one here?
>
> If you have a THP, we'll skip the page migration and fall through to
> split_huge_page_to_list(), then the smaller pages can be considered,
> migrated and reclaimed individually. Not that we couldn't try to migrate
> a THP directly. It was just simpler implementation for this first attempt=
.
>
> > 2. For the demotion path, a common case would be from high-performance =
memory, like HBM
> > or Multi-Channel DRAM, to DRAM, then to PMEM, and finally to disks, rig=
ht? More general
> > case for demotion path would be derived from the memory performance des=
cription from HMAT[1],
> > right? Do you have any algorithm to form such a path from HMAT?
>
> Yes, I have a PoC for the kernel setting up a demotion path based on
> HMAT properties here:
>
>   https://git.kernel.org/pub/scm/linux/kernel/git/kbusch/linux.git/commit=
/?h=3Dmm-migrate&id=3D4d007659e1dd1b0dad49514348be4441fbe7cadb
>
> The above is just from an experimental branch.
>
> > 3. Do you have a plan for promoting pages from lower-level memory to hi=
gher-level memory,
> > like from PMEM to DRAM? Will this one-way demotion make all pages sink =
to PMEM and disk?
>
> Promoting previously demoted pages would require the application do
> something to make that happen if you turn demotion on with this series.
> Kernel auto-promotion is still being investigated, and it's a little
> trickier than reclaim.

Just FYI. I'm currently working on a patchset which tries to promotes
page from second tier memory (i.e. PMEM) to DRAM via NUMA balancing.
But, NUMA balancing can't deal with unmapped page cache, they have to
be promoted from different path, i.e. mark_page_accessed().

And, I do agree with Keith, promotion is definitely trickier than
reclaim since kernel can't recognize "hot" pages accurately. NUMA
balancing is still corse-grained and inaccurate, but it is simple. If
we would like to implement more sophisticated algorithm, in-kernel
implementation might be not a good idea.

Thanks,
Yang

>
> If it sinks to disk, though, the next access behavior is the same as
> before, without this series.
>
> > 4. In your patch 3, you created a new method migrate_demote_mapping() t=
o migrate pages to
> > other memory node, is there any problem of reusing existing migrate_pag=
es() interface?
>
> Yes, we may not want to migrate everything in the shrink_page_list()
> pages. We might want to keep a page, so we have to do those checks first.=
 At
> the point we know we want to attempt migration, the page is already
> locked and not in a list, so it is just easier to directly invoke the
> new __unmap_and_move_locked() that migrate_pages() eventually also calls.
>
> > 5. In addition, you only migrate base pages, is there any performance c=
oncern on migrating THPs?
> > Is it too costly to migrate THPs?
>
> It was just easier to consider single pages first, so we let a THP split
> if possible. I'm not sure of the cost in migrating THPs directly.
>

