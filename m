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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 973C5C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:51:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B6792085A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:51:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TpMwHjVt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B6792085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB1088E0007; Tue,  2 Jul 2019 23:51:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D395B8E0001; Tue,  2 Jul 2019 23:51:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C28A48E0007; Tue,  2 Jul 2019 23:51:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5148E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 23:51:23 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q79so533888ywg.13
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 20:51:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hseDA+bD8a6F14cMB36/4WyoSxV6I8ksid2R1eVvWPc=;
        b=IRYZIC5/VPM98Zxj2RQC1LEIcNbTuv1uxR7gBo0yMxHmAvjmwd9LsQN6M+Fy6XePO3
         CHF/7DR+stdENLP7s1/AJQ3aquh1l++EH1FaNVwwJBV7lPrbSOGma0hNprtZRhxSoKRW
         /Zs5aIP2viFnKj0Ih2asxbajXKS2pMFK2BIlvE2Rqrz6D29tywYwnNvUiOaZIqLwN2GN
         azvjzumYRqiu5Ulod/0hzVI8oEw+C/6wt3ocGTUjvP/w+xHBUAuU4mvbcupc3rBEY7Jz
         S5fbUPGfJvU2/q5W0CtLtKhGFX3iYnW60e1Tl/6pZiykfRXkwQeO8Jepp+xeHo75+vIW
         gUCw==
X-Gm-Message-State: APjAAAWgnkd5EjMkoxOpjUcUco5uwN3IPBWnJYE1PcAFohCDWJF87YnE
	ejM6IchPyG8JTxQF5SekU8f4Gg/UZntoHcW2Y9B2dcBPqu8797Etb612M5Ds6Q3i63dGM+xmovP
	RY9ClP3+5CmdwjP90nBCxK8xBt184sqSCz03QwQ5O2atDsxDe+TTeNjhYZAoyq6QIJw==
X-Received: by 2002:a81:7083:: with SMTP id l125mr21946953ywc.194.1562125883437;
        Tue, 02 Jul 2019 20:51:23 -0700 (PDT)
X-Received: by 2002:a81:7083:: with SMTP id l125mr21946928ywc.194.1562125882956;
        Tue, 02 Jul 2019 20:51:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562125882; cv=none;
        d=google.com; s=arc-20160816;
        b=R5vybBlApLnZua3BLcfNCDN0QcKhhgUMLOqsSnRHS0a1JlnTMZiZlXVAhD6iJs9iy4
         8Arz2GHlqs6McI0JV35AnVd36fFSieQnOzC32PatkWOnwAwFI+uGkdKcWny8twUBagr6
         Pic7920ffL/7RTgpiGRipwURQKBGfIjDLuOjerqt4jaaesvzpWmssJAmjy5/zCLe6SVM
         GNtCLJ0eDYTGyUArMNQ8JUZ4/MZykAUUB7aOSGwVTiUlk88UDk74+lVykq6JJ8ZglVmZ
         l/kc7FM2qSZ1CGEz2FJvXUfFva0ZOCQ2ZpVA/6mFAnvAmSylbYotNP7gwPrGlMqMg2t+
         XDvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hseDA+bD8a6F14cMB36/4WyoSxV6I8ksid2R1eVvWPc=;
        b=xRU3VCVWpI8/tT8t1B9L0Na9C0MlmzuZnyg1tQx5RZyfRL2vqdRry5nI61uvOzqUHv
         lemQV9JNnlWcxXWvhW23JyRQoDNF0jwB3DVCT/zgpC1kH6Aj3+GM9pHcStoVL6j7HkP+
         p8cB44LYwipvZVWRUUF0SPIgQSQKMHbunsLoh4Jvi6S0Bwwzw3FPwAFLkKfM8u+bH4V0
         5R+JN4Vv1XfWt1MQgJ+IbEg8Lq5NRn3QzUqW0mqDVwzXdPcMskFeFdYu8gtxf+/JMWo7
         a7rxHG6z2VTSFRVQpKCSMwC8PsokO7vSSTraaKLP6f3mAzu824G5Lk/P0aGOhFDLDYlP
         Ta1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TpMwHjVt;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s10sor548432ybj.198.2019.07.02.20.51.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 20:51:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TpMwHjVt;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hseDA+bD8a6F14cMB36/4WyoSxV6I8ksid2R1eVvWPc=;
        b=TpMwHjVt9xOyXpA9Mx/2zf7DVbHzwAoHV9qjcg6AcBGSbr4RjV/JUJLoivojHcfR61
         HCBjJa6yFSvvHhDEEXZ4qnaMHu69MlkOLtBM/NjBt37qT2scBip7Xv/QfcAU9OFzpdne
         nLY8b3y5jrCLgIHwWKbMMc/Zkqo8yD5oYNvZ9Mvhvnk6ssOm8FDMRntye1bhwQnTTdmG
         Lxp6HJU5g2QfdfB9wn64XZQsKIJX+O234Yeq3aiMs6ja+AnUv6ZwpV5vR8iEPNdA7myc
         wnYFkOmIN9Miz4bSeayb5tyOS3Phyh4EBT1jauOV3UB6J8udYva3PdEFVR7HUjNO28ZF
         +ukw==
X-Google-Smtp-Source: APXvYqxodg80K7mjomG3dph2SOcms0CGDfT0gVCFNzmGcaxkNPCF7b99S4oHVnVYNEmu97/wdpFjso8JhpU04T9/vmY=
X-Received: by 2002:a25:9903:: with SMTP id z3mr89658ybn.293.1562125882387;
 Tue, 02 Jul 2019 20:51:22 -0700 (PDT)
MIME-Version: 1.0
References: <1562116978-19539-1-git-send-email-laoar.shao@gmail.com> <CALvZod68TeAJ_CRgZ0fwh6HhHOwrZ9B4kwMHK+kycPmhR4O46w@mail.gmail.com>
In-Reply-To: <CALvZod68TeAJ_CRgZ0fwh6HhHOwrZ9B4kwMHK+kycPmhR4O46w@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 2 Jul 2019 20:51:11 -0700
Message-ID: <CALvZod4ZUPWSeD1XoDoXc6LCoHkqjkoXTjJbOB_fsbLQnd_fLQ@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: fix wrong statistics in memory.stat
To: Yafang Shao <laoar.shao@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+Johannes for real

On Tue, Jul 2, 2019 at 8:50 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> +Johannes Weiner
>
> On Tue, Jul 2, 2019 at 6:23 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> > When we calculate total statistics for memcg1_stats and memcg1_events, we
> > use the the index 'i' in the for loop as the events index.
> > Actually we should use memcg1_stats[i] and memcg1_events[i] as the
> > events index.
> >
> > Fixes: 8de7ecc6483b ("memcg: reduce memcg tree traversals for stats collection")
>
> Actually it fixes 42a300353577 ("mm: memcontrol: fix recursive
> statistics correctness & scalabilty").
>
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: Shakeel Butt <shakeelb@google.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Yafang Shao <shaoyafang@didiglobal.com>
> > ---
> >  mm/memcontrol.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 3ee806b..2ad94d0 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3528,12 +3528,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
> >                 if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
> >                         continue;
> >                 seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> > -                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
> > +                          (u64)memcg_page_state(memcg, memcg1_stats[i]) *
> > +                          PAGE_SIZE);
>
> It seems like I made the above very subtle in 8de7ecc6483b and
> Johannes missed this subtlety in 42a300353577 (and I missed it in the
> review).
>
> >         }
> >
> >         for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
> >                 seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
> > -                          (u64)memcg_events(memcg, i));
> > +                          (u64)memcg_events(memcg, memcg1_events[i]));
> >
> >         for (i = 0; i < NR_LRU_LISTS; i++)
> >                 seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
> > --
> > 1.8.3.1
> >
>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

