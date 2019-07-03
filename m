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
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF53FC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 993B521871
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:17:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ubsVNmJ9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993B521871
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EE6F6B0003; Wed,  3 Jul 2019 01:17:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29FB28E0003; Wed,  3 Jul 2019 01:17:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1676B8E0001; Wed,  3 Jul 2019 01:17:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB75B6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 01:17:11 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id a9so803293ybl.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 22:17:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1ph5YKpr5eYPLkWW+A9D3mF8JzIssbrCteby1s+tBFQ=;
        b=XJQxwPvb61Kk6N+e1RBtb7Ule3VlN6EdPYsJeHp6OLfhADRkEtD0FTbELCKnMHu8AC
         wHY3XyLKtQq5PmNqINIFU+jzcsRDzm7DAZLc21Ij4eDBnotQQqs6pndX+pE+vV8/4y9d
         J0OJqwIZVsLOC7aNdtX4EGMC3Qzs4YwMiZ+vPI+PfkPD2w6gP0IvMnpHMtnV5k0QTr49
         idOwnppuExwBZ+Bzr/S5yJL4qZloeedNGVq6WomLplj88bCNzNv1Ov/1a+G+Ci4uPhl/
         18DjDzMARcfckF4Fg3NphlOdVhticCpzeRT7PuwvWW9V+Fjn1DMemIoJBxvsnPwcjEjZ
         a8BA==
X-Gm-Message-State: APjAAAV+fG/yqCo5iUu/XMMJ/5b+sSx3kRxQwyh3D7Tngxui5Se4CaNS
	IHlN7jOPbSMszQVwtmOAIXQ7xA4xFfLTVGPQZmzT81k5fSQl14ASAFmK+Q4F2grDY+wJcyM39Vu
	uD/UIe6H9nf4PFuVgl2Kpi8yyv8RWRBOYpoG4xuOYpRAK/4aizHquvvjDiPb7glvTeg==
X-Received: by 2002:a81:32d0:: with SMTP id y199mr15851746ywy.342.1562131031634;
        Tue, 02 Jul 2019 22:17:11 -0700 (PDT)
X-Received: by 2002:a81:32d0:: with SMTP id y199mr15851723ywy.342.1562131031010;
        Tue, 02 Jul 2019 22:17:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562131031; cv=none;
        d=google.com; s=arc-20160816;
        b=NcSWT0wa6tImPoG/20ncrIbcypnqc/caRv2mqurmmclXhm6majwvh0phJ4OSVCEQrV
         aoQPvyhAtHCfzEy8oexdWFm/a9+7X4SLAHLbRDwkh1ovK50xIOUhNwWqJwEih7o9smmD
         lBmV3ndRw90FLXELlfRqJyvUTits+imKg9zRr/woo+CSItjDNERep0p0XzcMiXY6w9M0
         8Z4UYrduj5Reop2GX4QsTFzIkx4vSHWhlFpjPjQ5FVTUjYdodvJY5hsuXxtWhGuEgCRx
         CNM9sEhuHcizO9JnNXm8P3Ksk4fUdVqgttihPB6VyTU+2lWlUFA5H65n7cVbd8F+9Fun
         c+Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1ph5YKpr5eYPLkWW+A9D3mF8JzIssbrCteby1s+tBFQ=;
        b=mDVWZ89+14+wbxqc4nV4JHNShbpyGF254D3c/PbI+DfROQCY5Kj3GpZJtrJ+ONTCPR
         Qt04Mnap6UBHc+uCX8XoP/AjycsiY2q1jVZXJsBbO4uuov3PqXHtkATpm1ORJwARL01r
         8+MnGfeZqz4T1Fu9ktuzlgzytX27boOwjk0o42v6ls92apTruMuUnHHFEyuoegTGOb+l
         70vAjDuwOVZ8N16mcyxQV8wwA1TipoqaU6hLcvyBVgGbpaqeNit+0RRnl1P7cj8FYVCY
         c03PTWLNCNw2kEg7cRITsG67nvFBE+Hk0giYDO8nFjPmed60QtqyYjSaKo/pg4mcU1e4
         RrMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ubsVNmJ9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor520190ywv.59.2019.07.02.22.17.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 22:17:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ubsVNmJ9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1ph5YKpr5eYPLkWW+A9D3mF8JzIssbrCteby1s+tBFQ=;
        b=ubsVNmJ92hzCpChbUKvpqlUqrGKfr6az5Hoe1p6P5qhwrKWQ3pee5GEKCLyMG9SaZW
         STflCRRuwc8MIbJoE45f7Gu/PYN7vtToYuqyLdGxNQF8wNQ1qYZNIJKOnZ7BpHuX0zh5
         wjAi4wPF57wSRdrIf9EaNpMXzCMvvmh6g877W5h7NVG9KCKAo6aR1TUs1xkBbBQBM2bw
         /SlTQC6nzBlOXD+t3UAyaoNhXDqsOhFWLPTx5M6yRNylxNC9OIDkc10nBG6bmq/1Kow3
         tI0oXLeBuoRpjCufvV3I/XPgk2sp14KYOXvprf8bKsNUpjLn6VwazFKA6KeW9Y/FEoiv
         Q6lg==
X-Google-Smtp-Source: APXvYqz5i7w+Iawnuv0RR1pYVfBg5l3wdY6opbt/mD07g2+RTfsQdE4WaD9eCeQVGVcPKsxleE8QVBXIU6MctfhkdNU=
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr22081132ywh.308.1562131030277;
 Tue, 02 Jul 2019 22:17:10 -0700 (PDT)
MIME-Version: 1.0
References: <1562116978-19539-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod68TeAJ_CRgZ0fwh6HhHOwrZ9B4kwMHK+kycPmhR4O46w@mail.gmail.com> <CALOAHbBOKxZKfZSf3-JhNOvM_m9gmYbMT+kNTBCdedOg4=kmLw@mail.gmail.com>
In-Reply-To: <CALOAHbBOKxZKfZSf3-JhNOvM_m9gmYbMT+kNTBCdedOg4=kmLw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 2 Jul 2019 22:16:58 -0700
Message-ID: <CALvZod5JOdYbdvePsYqjtHd=Kma9jZ_CYO5e+7Ma+z0Yszd5iA@mail.gmail.com>
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

On Tue, Jul 2, 2019 at 9:28 PM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> On Wed, Jul 3, 2019 at 11:50 AM Shakeel Butt <shakeelb@google.com> wrote:
> >
> > +Johannes Weiner
> >
> > On Tue, Jul 2, 2019 at 6:23 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> > >
> > > When we calculate total statistics for memcg1_stats and memcg1_events, we
> > > use the the index 'i' in the for loop as the events index.
> > > Actually we should use memcg1_stats[i] and memcg1_events[i] as the
> > > events index.
> > >
> > > Fixes: 8de7ecc6483b ("memcg: reduce memcg tree traversals for stats collection")
> >
> > Actually it fixes 42a300353577 ("mm: memcontrol: fix recursive
> > statistics correctness & scalabilty").
> >
>
> Hi Shakeel,
>
> In 8de7ecc6483b, this code was changed from memcg_page_state(mi,
> memcg1_stats[i]) to acc.stat[i].
>
> -               for_each_mem_cgroup_tree(mi, memcg)
> -                       val += memcg_page_state(mi, memcg1_stats[i]) *
> -                       PAGE_SIZE;
> -               seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
> +               seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> +                          (u64)acc.stat[i] * PAGE_SIZE);
>
> In 42a300353577, this code was changed from acc.vmstats[i] to
> memcg_events(memcg, i).
> -                          (u64)acc.vmstats[i] * PAGE_SIZE);
> +                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
>
> So seems this issue was introduced in 8de7ecc6483b, isn't it ?
>
>

That's the reason I said 8de7ecc6483b made it subtle but not wrong.
Check accumulate_memcg_tree() in 8de7ecc6483b, the memcg_page_state()
and memcg_events() are called with correct index but saved at 'i'
index in acc array.


> > > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > > Cc: Shakeel Butt <shakeelb@google.com>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Yafang Shao <shaoyafang@didiglobal.com>
> > > ---
> > >  mm/memcontrol.c | 5 +++--
> > >  1 file changed, 3 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 3ee806b..2ad94d0 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -3528,12 +3528,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
> > >                 if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
> > >                         continue;
> > >                 seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> > > -                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
> > > +                          (u64)memcg_page_state(memcg, memcg1_stats[i]) *
> > > +                          PAGE_SIZE);
> >
> > It seems like I made the above very subtle in 8de7ecc6483b and
> > Johannes missed this subtlety in 42a300353577 (and I missed it in the
> > review).
> >
> > >         }
> > >
> > >         for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
> > >                 seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
> > > -                          (u64)memcg_events(memcg, i));
> > > +                          (u64)memcg_events(memcg, memcg1_events[i]));
> > >
> > >         for (i = 0; i < NR_LRU_LISTS; i++)
> > >                 seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
> > > --
> > > 1.8.3.1
> > >
> >
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>

