Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D290EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:44:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7722C21855
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:44:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cd/lj9oL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7722C21855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 126198E0003; Thu, 14 Mar 2019 06:44:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D59A8E0001; Thu, 14 Mar 2019 06:44:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2D5E8E0003; Thu, 14 Mar 2019 06:44:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC0E18E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:44:22 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id i4so4313328itb.1
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:44:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qd8n3KqbDahoPwCZIcSO29r3/qbS//0/Sc4AHCuc2OA=;
        b=i3dBsi4IhL7IxIftFtMt1w6g6u5GiBpVwR0AkZ+80sBPclm/0PYilAm533pR6mqTmM
         iGTjjvs97lGnTE5FvhRw5wlntLoQZ9j9MvRlxQKDsyXIX4bUOWODGdT6YioqVtQotHLW
         JUG5/G0KrwTEK4TmNaDPqSuvaxRGEopzTRAeUFVg5MDT1XrCEcT2OoKAD33O+GDrKtF9
         YhcsDeVBBnLsYpdwq4BM+iV2qa99iUjKzz/Hqa08BmmVAm0HQ2GtrnsoE8hgFHpOGFEe
         yA4fnKUO217xfP751UQeBVwsPRvUQzqfxgC+Y5tQI4kslwv7/ceDvSMsKX/xK6mKGH7A
         R1Vw==
X-Gm-Message-State: APjAAAXf2sDA2K2WI6+G8jnuJRl52i+l5nzc4342BG3Rm/3V1Imur4xJ
	CBry//n4Kts92M6I5ai8sZlOiecz04ScPy4dzJTlDxDI2iFPnsK/8qUlfekNczCIJCqrAVdVDY6
	Z7jTkdOhd0GipV97j46KPAE0m41TxyuTAQIwV0DLWwnzzysWVZ9OAYbTgMNsGvPqT4IuycV3Wb0
	3SG3BJB/xYypOdg3Cxu16Syp63RibN3ronIoLzP9kQ0SuUXM/0p113+tVrFso8s2EC4nSVCkFF4
	9GMrfPkXRUgUaUbi9ZHqohvr9XCfW2/l28rbVW4JLRL2py3Vjwa717W/lnUkXn7yT1kPw/v71az
	JtRQdT1DAIc9rnkumrgOfi8uDAkIDlw4JFBHlCd63fs8PT/jgI2kOQKoQjZbjB9vBWm3jotDARG
	p
X-Received: by 2002:a02:1783:: with SMTP id 125mr11693177jah.31.1552560262567;
        Thu, 14 Mar 2019 03:44:22 -0700 (PDT)
X-Received: by 2002:a02:1783:: with SMTP id 125mr11693130jah.31.1552560261177;
        Thu, 14 Mar 2019 03:44:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552560261; cv=none;
        d=google.com; s=arc-20160816;
        b=sjAdD4jJnhaMdtuDgM3WHAdN5AgU9EONjR8eiamPieVWXKi5wh7a3Bn2RU4acfKQzw
         p5VaV8ZmT0vD7C5cRvPsryu9mO30PRPyyWQ0AwAOJGLFMw6KReSbRo7QsuITkqSqyIA0
         edwdjGePOuilYBVBocMeKLjTSam6w4XuoECzaScZcudxiPchQ/tFcjgiVpktYKHGbdjQ
         XkZU1CEgvjeGJaPTVLAyEJFcHHpXiigtmm9k+3SZImJcT9DQAOYXSKsg1U0gMn+kbYK8
         2WpHExOJtFHNN4VAXyUZ63ZNq47sp4o6/PvNBUbAwmSro+ytHZ0aqOS5MWmWtqG+064+
         UebA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qd8n3KqbDahoPwCZIcSO29r3/qbS//0/Sc4AHCuc2OA=;
        b=H5VZWcBK/Tz45741jc21zPwMDnnOXI0CCKvnSQXssViXNXY5XakTK127Fnjha+8ZJu
         yBtI9s3Mges2cF2ti3i7D8/dvqkB/0HUGDQWtrAvV0JWo4ar89HjLB4Rx3+WcNO3X8Ec
         ZEc1vi07AaoJZbqfqNEPyictds3ghJnEkaj/gUhE+9A+7OvfGvebdmd4vgFssyr6uzA2
         jd4kd6I7ECn5QRFunytoM5FzQm2GxDYHRogOyHOsCGNsqC9kbz33COUM02ADiRH9JmrL
         baf76l4PPE7WgGaLnSFVjYqypl9kRhlEVy8OQUYTPW5K1Mxw/R5EhMuaDMHk1O8F+Hsl
         tmSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="cd/lj9oL";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b102sor2638299itd.30.2019.03.14.03.44.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 03:44:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="cd/lj9oL";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qd8n3KqbDahoPwCZIcSO29r3/qbS//0/Sc4AHCuc2OA=;
        b=cd/lj9oLnlnFZtNouHHalTbuFniLYV5Qji+yNGwBxL7Qa2yMXRBYYpJtbMf1TLG1aO
         IwS13cvtko4rV1IjGpftQ0GkqOHurddGkGrpSzWMTuRg9YqOsEDpE0H0YNtg8t4v26Zv
         mPJwZ2xRjLUj73DaX0T84XAhQ4fVGOSwpgKvPobeLnV4WG3r0YAoZGASKJicfSaIF3Gi
         9eL5XjQsLUjEihVdVkyx+UEi2qwn1MgGLKwLpOQwPNFZAhcprFHNB62Xw3vxwqjpxAbF
         hP1aI61EdhP3zQ7JuMNTjfpKHXt538V9jppV2VY3wl0Gd6P1ftrt0X22PcRymRU2M8SJ
         X8Ig==
X-Google-Smtp-Source: APXvYqwTZ2icNGbQbSX9V2gpjOJMOh3gHL8RUUHTBbZgmkW7UUxUjnRP77DQXawmmoMxdJ/jxOWWhU4yRpZ6YrbHsdc=
X-Received: by 2002:a24:b34f:: with SMTP id z15mr1543254iti.97.1552560260894;
 Thu, 14 Mar 2019 03:44:20 -0700 (PDT)
MIME-Version: 1.0
References: <1551421452-5385-1-git-send-email-laoar.shao@gmail.com>
 <1551421452-5385-2-git-send-email-laoar.shao@gmail.com> <20190314101915.GI7473@dhcp22.suse.cz>
In-Reply-To: <20190314101915.GI7473@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 14 Mar 2019 18:43:44 +0800
Message-ID: <CALOAHbAuGLe_Cw+xChmM3=cuhdis3=LwaT1yRoH72zmg+uhUTw@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: drop may_writepage and classzone_idx from
 direct reclaim begin template
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 6:19 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 01-03-19 14:24:12, Yafang Shao wrote:
> > There are three tracepoints using this template, which are
> > mm_vmscan_direct_reclaim_begin,
> > mm_vmscan_memcg_reclaim_begin,
> > mm_vmscan_memcg_softlimit_reclaim_begin.
> >
> > Regarding mm_vmscan_direct_reclaim_begin,
> > sc.may_writepage is !laptop_mode, that's a static setting, and
> > reclaim_idx is derived from gfp_mask which is already show in this
> > tracepoint.
> >
> > Regarding mm_vmscan_memcg_reclaim_begin,
> > may_writepage is !laptop_mode too, and reclaim_idx is (MAX_NR_ZONES-1),
> > which are both static value.
> >
> > mm_vmscan_memcg_softlimit_reclaim_begin is the same with
> > mm_vmscan_memcg_reclaim_begin.
> >
> > So we can drop them all.
>
> I agree. Although classzone_idx is PITA to calculate nothing really
> prevents us to have a tool to do that. may_writepage is not all that
> useful anymore.
>
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>
> From a quick glance this looks ok. I haven't really checked deeply or
> tried to compile it but the change makes sense.
>

Thanks for your quick response!
This patch works fine, I have verified it.

> Acked-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  include/trace/events/vmscan.h | 26 ++++++++++----------------
> >  mm/vmscan.c                   | 14 +++-----------
> >  2 files changed, 13 insertions(+), 27 deletions(-)
> >
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index a1cb913..153d90c 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -105,51 +105,45 @@
> >
> >  DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
> >
> > -     TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> > +     TP_PROTO(int order, gfp_t gfp_flags),
> >
> > -     TP_ARGS(order, may_writepage, gfp_flags, classzone_idx),
> > +     TP_ARGS(order, gfp_flags),
> >
> >       TP_STRUCT__entry(
> >               __field(        int,    order           )
> > -             __field(        int,    may_writepage   )
> >               __field(        gfp_t,  gfp_flags       )
> > -             __field(        int,    classzone_idx   )
> >       ),
> >
> >       TP_fast_assign(
> >               __entry->order          = order;
> > -             __entry->may_writepage  = may_writepage;
> >               __entry->gfp_flags      = gfp_flags;
> > -             __entry->classzone_idx  = classzone_idx;
> >       ),
> >
> > -     TP_printk("order=%d may_writepage=%d gfp_flags=%s classzone_idx=%d",
> > +     TP_printk("order=%d gfp_flags=%s",
> >               __entry->order,
> > -             __entry->may_writepage,
> > -             show_gfp_flags(__entry->gfp_flags),
> > -             __entry->classzone_idx)
> > +             show_gfp_flags(__entry->gfp_flags))
> >  );
> >
> >  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
> >
> > -     TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> > +     TP_PROTO(int order, gfp_t gfp_flags),
> >
> > -     TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
> > +     TP_ARGS(order, gfp_flags)
> >  );
> >
> >  #ifdef CONFIG_MEMCG
> >  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
> >
> > -     TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> > +     TP_PROTO(int order, gfp_t gfp_flags),
> >
> > -     TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
> > +     TP_ARGS(order, gfp_flags)
> >  );
> >
> >  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
> >
> > -     TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> > +     TP_PROTO(int order, gfp_t gfp_flags),
> >
> > -     TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
> > +     TP_ARGS(order, gfp_flags)
> >  );
> >  #endif /* CONFIG_MEMCG */
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ac4806f..cdc0305 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -3304,10 +3304,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> >       if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
> >               return 1;
> >
> > -     trace_mm_vmscan_direct_reclaim_begin(order,
> > -                             sc.may_writepage,
> > -                             sc.gfp_mask,
> > -                             sc.reclaim_idx);
> > +     trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
> >
> >       nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> >
> > @@ -3338,9 +3335,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
> >                       (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> >
> >       trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
> > -                                                   sc.may_writepage,
> > -                                                   sc.gfp_mask,
> > -                                                   sc.reclaim_idx);
> > +                                                   sc.gfp_mask);
> >
> >       /*
> >        * NOTE: Although we can get the priority field, using it
> > @@ -3389,10 +3384,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> >
> >       zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
> >
> > -     trace_mm_vmscan_memcg_reclaim_begin(0,
> > -                                         sc.may_writepage,
> > -                                         sc.gfp_mask,
> > -                                         sc.reclaim_idx);
> > +     trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
> >
> >       psi_memstall_enter(&pflags);
> >       noreclaim_flag = memalloc_noreclaim_save();
> > --
> > 1.8.3.1
> >
>
> --
> Michal Hocko
> SUSE Labs

