Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA73EC10F0F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 23:24:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69263206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 23:24:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NW4GvuGn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69263206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 065756B000E; Thu,  4 Apr 2019 19:24:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 013736B0266; Thu,  4 Apr 2019 19:23:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E47B66B0269; Thu,  4 Apr 2019 19:23:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 952AA6B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 19:23:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f2so2269971edv.15
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 16:23:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aQmFptRCMNJUXqWNlG7Ngtr4WD0bD7Lax90R8JIeGM8=;
        b=VerWokeQGztbhmVeA1GAz8Qbd3BV23rSTFmHMMmW4DiU4jG5zectFg7DR8bGcfKRxJ
         6DBJmp4uDbzy1Bvt7qBD2IHxga1gmbajz0x/l5a/OpIT+fM2+H5kCf44iLxKaI7z9xy6
         jZLiINRmtrqZizYoI3slVE1NBALVz89MXvlRaEFMcPb5IroocXCVwd/36qYpUYhSA0in
         NrUdsxjRXmp8q8wfkzeUHXwWJEA9B45EeeatXHfiKH8KitawIOkbonIPREglb+EExw1L
         7PU5WdqXCTJG/AA5cqjxlt0em8ANrH2IIWYQyToT8OXLQgv1FoxyuIG6IkM8LM31UxU6
         WZcg==
X-Gm-Message-State: APjAAAVOQ9c5tn+0nAMiFDyKHXQrGVlNmkMWlGhEza3YZqNFwMkjTYNP
	CZA0+GaxbUjZWoLjqCNK1V60ep4iPupahvmgW6YfoF79KYfpoN+ESxs4CqcVFq+Jz68GuG3nt1B
	/mTQoDrdEMgy+D+cPXK3Anbq/zhxHZJhxZN0aWmm7nzF9EUsFihtEUqL/6kByzfNo/A==
X-Received: by 2002:a17:906:16ce:: with SMTP id t14mr5181664ejd.244.1554420239054;
        Thu, 04 Apr 2019 16:23:59 -0700 (PDT)
X-Received: by 2002:a17:906:16ce:: with SMTP id t14mr5181606ejd.244.1554420237642;
        Thu, 04 Apr 2019 16:23:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554420237; cv=none;
        d=google.com; s=arc-20160816;
        b=iQtOk3NJ84aVpHPToxJuXlKWN6C9XE+nA76t9L3iyWGHi4Udp49PHrPADeToMzicvi
         zZbGY7H7q1fwwEWZx8253FLSSXRogGBpKLtn4TDmeLlcNG8UC/wy5z28uS1cetdC1oiB
         EjoRmuCvKEGeUVOgG/1OGpIYue/bd5x/pW/Wc5Car+/B98VFgYK/4mauXBM3HY+EGjXz
         wvrOrNJFQxvafoDSs0uUPQcvexNMk7dUAnbrWc13xJFh7crk4afFA7U1Q3aywNbP+bBk
         thLgD94V5ANYOq9RJCVmIBwg/sN5DVu+mw6u2rQE6KAVXwFx196DHF/A0C+OeTL5katv
         CQ9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aQmFptRCMNJUXqWNlG7Ngtr4WD0bD7Lax90R8JIeGM8=;
        b=TeZFwFBJCzbl6USheALj0G+DadtctwVVBvWezmE1q67AHYYvqfiwlvqf+GfCN8VO5X
         P3C+E+op49FeAt6dfiYLoEiz5Y/+zJ4ZnN4o6ydM2P7jk37QHwwS36028mtQoLQBcVoh
         HyJ8lVPq7imTmSzquT3S3+9iJowCZyzgXIiYNwCLnwgYL1KgdYfrL5Yg/Q7g+3Fa0m4N
         8z3Y4FfzFlwgyTQKxgQWuaRIz43Iu6ppBPkfoOl+8pFnhUoa9AFaqF1JNFpW8xSlTYnh
         olF8UIRKk146BYLypSpyJEz4xnLrKfq8nsLitxnNwwqNYhIvF0p8xiAzNXaD3SyOXhJP
         S17Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NW4GvuGn;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 30sor12339474edu.6.2019.04.04.16.23.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 16:23:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NW4GvuGn;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aQmFptRCMNJUXqWNlG7Ngtr4WD0bD7Lax90R8JIeGM8=;
        b=NW4GvuGndPKFA7keaygmFDAXwp5CI+w9ZQp3InVI/99p1G8R5xbgp4cTsJRUxSTe9y
         HByHqPrq2noZJX8O6iPPiKq3Zr+cfKmBtF00K9BrznkKnlum0k7Nwrhx7tyF5NlJOHSV
         45LGI+oBdyq/ApcptsqcPK7fsn69vQBkcwAkgYV2vRlBeAlF6VDwjp0AugcTwl3+klQd
         tdGwINuu9wvyOC52mBvm1EauiZIa4wOiVveh90sz2FGRUpJatBthj+H33uXjhIi/rrUS
         RB/vIGXyX/bBgOJJFluSzhcCQEfmW6+Jt1NraodcSkK020RD0FSwwSoGcSozRk7NoeCc
         Z4oA==
X-Google-Smtp-Source: APXvYqxBzgnt/PBRH1nTXiLhk4TY1R/NnJ5ZgUWqjraQ1s5vhgvI/k4rRr4Fe8SJrmOB9acp2jJtq/tDPRQwy85M+Jk=
X-Received: by 2002:a50:b6d5:: with SMTP id f21mr5626526ede.105.1554420237228;
 Thu, 04 Apr 2019 16:23:57 -0700 (PDT)
MIME-Version: 1.0
References: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com> <20190404163914.GA4229@cmpxchg.org>
In-Reply-To: <20190404163914.GA4229@cmpxchg.org>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Fri, 5 Apr 2019 07:23:46 +0800
Message-ID: <CAGWkznHeGeiHWSF-gPmSW=AWQcEybHroOuP4CSbW4rKq12LtNw@mail.gmail.com>
Subject: Re: [PATCH] mm:workingset use real time to judge activity of the file page
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	David Rientjes <rientjes@google.com>, Zhaoyang Huang <zhaoyang.huang@unisoc.com>, 
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>, 
	Matthew Wilcox <mawilcox@microsoft.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 5, 2019 at 12:39 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Thu, Apr 04, 2019 at 11:30:17AM +0800, Zhaoyang Huang wrote:
> > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> >
> > In previous implementation, the number of refault pages is used
> > for judging the refault period of each page, which is not precised as
> > eviction of other files will be affect a lot on current cache.
> > We introduce the timestamp into the workingset's entry and refault ratio
> > to measure the file page's activity. It helps to decrease the affection
> > of other files(average refault ratio can reflect the view of whole system
> > 's memory).
>
> I don't understand what exactly you're saying here, can you please
> elaborate?
>
> The reason it's using distances instead of absolute time is because
> the ordering of the LRU is relative and not based on absolute time.
>
> E.g. if a page is accessed every 500ms, it depends on all other pages
> to determine whether this page is at the head or the tail of the LRU.
>
> So when you refault, in order to determine the relative position of
> the refaulted page in the LRU, you have to compare it to how fast that
> LRU is moving. The absolute refault time, or the average time between
> refaults, is not comparable to what's already in memory.
How do you know how long time did these pages' dropping taken.Actruly,
a quick dropping of large mount of pages will be wrongly deemed as
slow dropping instead of the exact hard situation.That is to say, 100
pages per million second or per second have same impaction on
calculating the refault distance, which may cause less protection on
this page cache for former scenario and introduce page thrashing.
especially when global reclaim, a round of kswapd reclaiming that
waked up by a high order allocation or large number of single page
allocations may cause such things as all pages within the node are
counted in the same lru. This commit can decreasing above things by
comparing refault time of single page with avg_refault_time =
delta_lru_reclaimed_pages/ avg_refault_retio (refault_ratio =
lru->inactive_ages / time).

