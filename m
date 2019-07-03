Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	URIBL_SBL,URIBL_SBL_A,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76520C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 379562085A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:50:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c+WTuWp9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 379562085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B40228E0006; Tue,  2 Jul 2019 23:50:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF9578E0001; Tue,  2 Jul 2019 23:50:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E06A8E0006; Tue,  2 Jul 2019 23:50:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E48D8E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 23:50:33 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id h203so540220ywb.9
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 20:50:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cD+R5tujKr0pCOBAkf9YtaRDraXjQf6XCbhD/QLypQI=;
        b=Uw/Qc7dbYyaD8Mx/s/X5ulGJtrbUTg5T2IY2BTKy7tDR4Ni9WJULvuNPd1Ln3JubpN
         ya+TlBmDOogXWvN80j7ru8V709L3e7KGEhvLkFYl/vvnHv/mL434VtBUo4DiNISkLD5m
         p1uGt00sr/uIaQotcKTQ3ZJH1iW858A5XTRaF3VdNDWWApTkWo6Eoz+5PSitB8Ic0S5Y
         HW8ZkyXPI/r/sO6N7F84rKFx1kxy672EiO60whiJzPx6k/DgFTQDAhf1PksL+y5IIjMV
         QFYd2JjjmyxQC1As+6HfIDi52Ts/z9sH9+gZHWwGVvdQjQVy9L0CfyWwIl4cKNrUQ6st
         aLvw==
X-Gm-Message-State: APjAAAVd8SRflqX9GTyCJHxUjWDcfBzkUA1+TU5a/kS99B/S42fmHfIM
	XNmiq5DXeZFSHSMI/yiIvQT+TJ/mTof6r1PKarbOUQJkDXm0InmFqT/cd9ehUK1jmxsXmBzVPAZ
	ho9mfDo87OSTbahLdK1+QlfkQiZegr37x5ARXa1rBb9YXp2sghdvTPgeCw4/eLfEIag==
X-Received: by 2002:a81:a6cc:: with SMTP id d195mr20959842ywh.346.1562125833181;
        Tue, 02 Jul 2019 20:50:33 -0700 (PDT)
X-Received: by 2002:a81:a6cc:: with SMTP id d195mr20959817ywh.346.1562125832692;
        Tue, 02 Jul 2019 20:50:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562125832; cv=none;
        d=google.com; s=arc-20160816;
        b=BQQrvJbPGq/Rh2xE8qmqUrRg1Mwr+rpw7XPGrPTcxK0YhVx5aefvz40dxF0tK1fZAf
         iD6DKsDyqbapgK2lnDUW0Y+N1GLEIwBQka71stsQqBdJsG0SXS9EBJOrAajx8D1UqFSi
         l1CMMdoQJzEm1Z2aalplfrgxwKu6Y+z6leUMNgrjd5nISnad8Zmo39Oux1awDHLs4Lah
         zc3uML0tqUePC6B7ecmDtzylHlDAtTWzcT8VPggrYAaPTf0qK49SexOeGYmIcpLwLXtb
         +AxI8GFVReR1puDQJx4mSxT9pRDFz0XP/+yrXJIZGcUY40Ic0NQeGMSTqzTOvSDRkWUP
         0sdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cD+R5tujKr0pCOBAkf9YtaRDraXjQf6XCbhD/QLypQI=;
        b=NFlNDVa00lJg8ykT16ugnmVTgBJqbPsBkN6BAM9Xpwfy9VdDzcmOGl4t4M+Gr0f47d
         BWCpR/2TzHtARteEcTIzakYwb4Efg7rlTE0S6wNaU57GZaSttq5YQxZqeV78yBEyIS4W
         CKMXLOl0UVRpYufjE2fyfTLORqjp2hX0CHT0IPuFsdMjBTzJ2rUl3qU4Ha1CyrEKibfB
         vu/38K7aDZGsvFdntZvLAR8OSAKPxt5atfP5oQywxipZum771Of0btZwll6mAh5nQmpV
         ZHhAUyw+oUOwhZ83wuQ7aVjwXpx5sbr0f8fOmIaJWeYN/UIXmClUbXr6meUglUhJqwV3
         +k1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c+WTuWp9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r124sor449484ywg.55.2019.07.02.20.50.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 20:50:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c+WTuWp9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cD+R5tujKr0pCOBAkf9YtaRDraXjQf6XCbhD/QLypQI=;
        b=c+WTuWp9YxQWSSW7fbMsGj4OTVS3fGHuYIN2aR9+eXmptV0OH8X9tPNY3IwvyE/cxL
         EZ0wPgiWrvLeWp+wvmlGBzyX0mF4XfPYtnA+6XQkvqOQmTVVd1wvJRzMbl/dllCSz/Qf
         iLUsHOgtv7ntzSFE3nz8lL7cR7S6pZroVTmEltlXvr6YWDHHYb5gtVpfUKYmeN3MzJMU
         XwTL3rYPg+kEU5PRetWMjGsbsn3ltyxDAQN5SNC7uS9RjCbVFduPfTg8jmv0dCFtPP2q
         a2q9xOG23h0IODwhpSS2doxjJ2hBoeBE02BspCbJ0eWBoOJoutyR45oHmhumt7UDw2Eb
         6aeg==
X-Google-Smtp-Source: APXvYqxFJtDz06Uyu08MMNipQEzNXhw8ElNYKP4vyVgfsp36j3gKheNnMs7xdjJGnn8VUzqBHvoJViZmAktz0S6/vnc=
X-Received: by 2002:a81:4c44:: with SMTP id z65mr20804279ywa.4.1562125831982;
 Tue, 02 Jul 2019 20:50:31 -0700 (PDT)
MIME-Version: 1.0
References: <1562116978-19539-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1562116978-19539-1-git-send-email-laoar.shao@gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 2 Jul 2019 20:50:20 -0700
Message-ID: <CALvZod68TeAJ_CRgZ0fwh6HhHOwrZ9B4kwMHK+kycPmhR4O46w@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: fix wrong statistics in memory.stat
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+Johannes Weiner

On Tue, Jul 2, 2019 at 6:23 PM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> When we calculate total statistics for memcg1_stats and memcg1_events, we
> use the the index 'i' in the for loop as the events index.
> Actually we should use memcg1_stats[i] and memcg1_events[i] as the
> events index.
>
> Fixes: 8de7ecc6483b ("memcg: reduce memcg tree traversals for stats collection")

Actually it fixes 42a300353577 ("mm: memcontrol: fix recursive
statistics correctness & scalabilty").

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Yafang Shao <shaoyafang@didiglobal.com>
> ---
>  mm/memcontrol.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3ee806b..2ad94d0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3528,12 +3528,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>                 if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
>                         continue;
>                 seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> -                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
> +                          (u64)memcg_page_state(memcg, memcg1_stats[i]) *
> +                          PAGE_SIZE);

It seems like I made the above very subtle in 8de7ecc6483b and
Johannes missed this subtlety in 42a300353577 (and I missed it in the
review).

>         }
>
>         for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
>                 seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
> -                          (u64)memcg_events(memcg, i));
> +                          (u64)memcg_events(memcg, memcg1_events[i]));
>
>         for (i = 0; i < NR_LRU_LISTS; i++)
>                 seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
> --
> 1.8.3.1
>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

