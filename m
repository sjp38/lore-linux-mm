Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B9CEC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:22:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E20D20843
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:22:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GAaDgk7n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E20D20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDAAC6B0005; Tue, 14 May 2019 15:22:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8C7C6B0006; Tue, 14 May 2019 15:22:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7BB26B0007; Tue, 14 May 2019 15:22:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9820E6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 15:22:20 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b189so182406ywa.19
        for <linux-mm@kvack.org>; Tue, 14 May 2019 12:22:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YfOaL1oTnK5xA4uooC11ryURNw9L/10wivCSX2gcjCo=;
        b=NtHNVSN5tA4UKqnI28dvIX6BX/CXZigp45Q0N97NrrbRwm1/qEZKe7riLEYkavC8El
         JIr/15gQu2ugx+/gDdBfPZfhfyNvEwTPj2cZgfIEuuc4sdtkD9k2sK3qjByqKtsWu6kb
         gcMaNDPg97ZKkUXyQTWmLN5aHEu0bRlCPpVP1bLJw164R4L4SjgJM+WDqYu54M0jJTai
         W/+Cfd2pRXNJS9qkmFRNJnPNKlLsQF+N/0wYH4DL5JbiLRQ8Qe4fjTEArCDhEicv0ntk
         j/7PtM249QCkkajihXC/qDsv1LmnGHBbHKuSmP1jFNr9NYquCqn1woJlpCq7NTujT8RA
         ZDTQ==
X-Gm-Message-State: APjAAAVR+NEDbdLnhJQgnsOpdNH5G34dCNzKyrzPuxxQahVvvEnD+aPJ
	AjoyL8qbQVJbjiqCSmrvMxJktMBuyuD79dWeI32H/NqTvp/1xkzvDET2TE8G7B81+DM2EYPJvmX
	csT+5ZycFQdlqEPxzwoKaiGN5EpZP6MoCS8bv81kXchWdXcDQJVakqTyHKOQ2KaxkbQ==
X-Received: by 2002:a81:5044:: with SMTP id e65mr19636032ywb.513.1557861740393;
        Tue, 14 May 2019 12:22:20 -0700 (PDT)
X-Received: by 2002:a81:5044:: with SMTP id e65mr19635991ywb.513.1557861739765;
        Tue, 14 May 2019 12:22:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557861739; cv=none;
        d=google.com; s=arc-20160816;
        b=FBo+pZtQR+ja3NLlV2+GiWC9+ndaC6Gwi5605krZMcyq4ANdECCCpx2H//sLVriHaa
         8mlJRd+ZJnAKuIVrKwh8GE3IZBORys/r5FysO12+dAcYpEKXKmUN9VlDamPv8nfN3DNm
         9Gnp4GRyH9pElHG2rDOv2Yc6nyqE0hP00w77mMOH/dguUXOkeMviCOD4nZi18Kk/edpU
         1S/SVV0ivQFbwGIetk3NDAot9PMS3dqXWWhdSXntIzyFw5kNf/9erF8yApei2a16ED4e
         Ho/HRqY7QQ2+f7DAbtDF5Q1hG1Ng9gtjprXfePhYFv1DRFUiwC8GMipurONWuQD4dYNF
         g/xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YfOaL1oTnK5xA4uooC11ryURNw9L/10wivCSX2gcjCo=;
        b=rIfYkvOip7Ts5eX+kjJwMPdntOPCAdGLSuENhDggi4rbmUgnj1a8sDSVoqGi57lChI
         ZLsndkRApYYxG9wLhoUeSGQfIs2qm9upczkr6xXQM16jkZ9Vb2/iQoOtjRLjmC3QlbtG
         z8zF40OnMgMF2PypZGwHSTtlAreYVNltTY7DMGBdzO0hswXw6zmU92GdB3k49DSjLjWk
         6/NtOMVVof9iqL/7p7qzf2kjX6OdcEyjUwBNaw4+U/v4nC2YahXwzyLGDkVe0X23fsNH
         aCYHrttWiBqcVYMip62ADKXvqBOdcSNzADS/rBvJZlKekrQbNXn0XM96H5SJMKYMw9Ad
         IXeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GAaDgk7n;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 199sor8878139ybf.146.2019.05.14.12.22.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 12:22:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GAaDgk7n;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YfOaL1oTnK5xA4uooC11ryURNw9L/10wivCSX2gcjCo=;
        b=GAaDgk7n/tpFRiZ3MVfd/nTZvVS8gOy9QgwY0WSf+e6tOSWEVi0YrWAMv5RFGbDprW
         AjTBdJhyEJCjt5jOANifS7VPXwOs1izpQ8BJUlZI9YWzJXVBYvd/JcdbIcJBIH0/qsJ1
         c4PWmrJK0W5UxolQRTIAsskkAi4l2CLZZFPhxLpq7OePR8qRs4NhOZbAzQJfY5LoJXdd
         7wWIKB/86sHuEiWNzyWBGD2BwCh+MX18mViRjbaLzDupK9+NmsOZ2YhjXGjy5CQV3Ivw
         HwxFWXerI5hfYo9iqcWrLsrzxwQdbaVmFuOVKt1BHFvq7LErJFjomK170O3fUcF8HlJf
         C6kw==
X-Google-Smtp-Source: APXvYqwNKjYJPo2uyzeWK/NA8XlEn0uNWXXg6sEiEhbNoRPCR4NlWDGedEUVbzLNS0/MZ+0HUs31yTEYQIGcedAV4Fc=
X-Received: by 2002:a25:dcd0:: with SMTP id y199mr17267698ybe.464.1557861739144;
 Tue, 14 May 2019 12:22:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190508202458.550808-1-guro@fb.com> <CALvZod4WGVVq+UY_TZdKP_PHdifDrkYqPGgKYTeUB6DsxGAdVw@mail.gmail.com>
 <20190513202146.GA18451@tower.DHCP.thefacebook.com>
In-Reply-To: <20190513202146.GA18451@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 14 May 2019 12:22:08 -0700
Message-ID: <CALvZod4GscZjob8bfCcfhsMh0sco16r4yfOaRU69WnNO7MRrpw@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] mm: reparent slab memory on cgroup removal
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Date: Mon, May 13, 2019 at 1:22 PM
To: Shakeel Butt
Cc: Andrew Morton, Linux MM, LKML, Kernel Team, Johannes Weiner,
Michal Hocko, Rik van Riel, Christoph Lameter, Vladimir Davydov,
Cgroups

> On Fri, May 10, 2019 at 05:32:15PM -0700, Shakeel Butt wrote:
> > From: Roman Gushchin <guro@fb.com>
> > Date: Wed, May 8, 2019 at 1:30 PM
> > To: Andrew Morton, Shakeel Butt
> > Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
> > <kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
> > Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
> > Gushchin
> >
> > > # Why do we need this?
> > >
> > > We've noticed that the number of dying cgroups is steadily growing on most
> > > of our hosts in production. The following investigation revealed an issue
> > > in userspace memory reclaim code [1], accounting of kernel stacks [2],
> > > and also the mainreason: slab objects.
> > >
> > > The underlying problem is quite simple: any page charged
> > > to a cgroup holds a reference to it, so the cgroup can't be reclaimed unless
> > > all charged pages are gone. If a slab object is actively used by other cgroups,
> > > it won't be reclaimed, and will prevent the origin cgroup from being reclaimed.
> > >
> > > Slab objects, and first of all vfs cache, is shared between cgroups, which are
> > > using the same underlying fs, and what's even more important, it's shared
> > > between multiple generations of the same workload. So if something is running
> > > periodically every time in a new cgroup (like how systemd works), we do
> > > accumulate multiple dying cgroups.
> > >
> > > Strictly speaking pagecache isn't different here, but there is a key difference:
> > > we disable protection and apply some extra pressure on LRUs of dying cgroups,
> >
> > How do you apply extra pressure on dying cgroups? cgroup-v2 does not
> > have memory.force_empty.
>
> I mean the following part of get_scan_count():
>         /*
>          * If the cgroup's already been deleted, make sure to
>          * scrape out the remaining cache.
>          */
>         if (!scan && !mem_cgroup_online(memcg))
>                 scan = min(lruvec_size, SWAP_CLUSTER_MAX);
>
> It seems to work well, so that pagecache alone doesn't pin too many
> dying cgroups. The price we're paying is some excessive IO here,

Thanks for the explanation. However for this to work, something still
needs to trigger the memory pressure until then we will keep the
zombies around. BTW the get_scan_count() is getting really creepy. It
needs a refactor soon.

> which can be avoided had we be able to recharge the pagecache.
>

Are you looking into this? Do you envision a mount option which will
tell the filesystem is shared and do recharging on the offlining of
the origin memcg?

> Btw, thank you very much for looking into the patchset. I'll address
> all comments and send v4 soon.
>

You are most welcome.

thanks,
Shakeel

