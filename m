Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45148C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:35:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0393E218B0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:35:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zoxgixcq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0393E218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97D238E0003; Thu, 28 Feb 2019 05:35:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92E8D8E0001; Thu, 28 Feb 2019 05:35:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 845278E0003; Thu, 28 Feb 2019 05:35:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CEE68E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:35:13 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id w200so7869992itc.8
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:35:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=n1j+98FSrDpg32f5NKLaFgL1Gb2pNFMygOJPoirCPZ8=;
        b=BDwtdyM05cm6IMAGeaiMOgRnYrGnqhXdTzH3z2shX6VyqVwaCXWiKUX9PBvMqRy0tk
         QPTKYuwVt9Cq9fCjVnYds+E1gtdvkh94rVohH8iExHvN+t0u28p4DbxmVeQKgwI7YVH3
         Mf2Oa3HxR4/KJqh2UTjOnz3KlCE8lms3vKDA/3dWVnhbRyDxy87zGrEhjN9+uBNtI60U
         oHTsBQBI51pllnQO3cQ+hrtl4z9unYV6UD5o7i6Vf/qlfeyb7kztjBfmaSUHsONV8Mzh
         BHV3ODR2h+k7g6ZJI/TZB1eCzGJTdDib4j6muceCJThorwQPFH5hek9gu2OaDOKMiQbl
         tvFw==
X-Gm-Message-State: AHQUAuZjy1DSNfanuEI4oOqQ7bdAZRd8otZoSahhxUGe5n5aluUKHu5e
	ljv8GYJ/idDGNKPnKh8Fr4z9uw1RboEZx+5VUrB0ll2c9zw7lbjAIIaL0DnFVbzjdeQxFuKjT26
	SC6l4T0RkOMCy0yvqhwkQIYZe6LAcIaxC8cjm9mOw9vR4elc/sgGgTvC2e+1whWJ7g42+gelctH
	XqZjAE1WG6N4RnKclDZ3qGK8wVkBLeu1WIWbh/o6V772jYHSE7lvMZsDf/NungmJPasTb7Z/LO2
	2axMdNDRxUjLuF72CQOTC+8t3K4LmFHs19or7Wwof0q6bHvJSXjdObcOOILlH6M0I+BlNQe0NF0
	eyRMavDc//CeIGRB2Lo0f7bG+Qe++W80UUlpW8ccDG9uMNbQAH2M5Gmz447tTUk6qTbOkrk9xSv
	s
X-Received: by 2002:a24:b550:: with SMTP id j16mr2261108iti.34.1551350113156;
        Thu, 28 Feb 2019 02:35:13 -0800 (PST)
X-Received: by 2002:a24:b550:: with SMTP id j16mr2261091iti.34.1551350112202;
        Thu, 28 Feb 2019 02:35:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551350112; cv=none;
        d=google.com; s=arc-20160816;
        b=cdoXpn70pjsm69UIBtgUM+8a63AwegJfacJA8HjPB1epw5z7ypQED2mDZbRRPAWyff
         kvLt/ezbOAsste0JZBOD847z1LWI2muOkutUA8PLdlYti2AlbkPg9cbkPkjsMSdUhytZ
         LQeElkktC81Fvf/5J/rlxL5fEqeGtvlQ23nE+X6j4C1Gv8Nkj3GJ9r9w4Gp4n9H6wryl
         C7GKS7brLKXE/hTHB5+yP55OcS6AqqYyE8JlyKGae6DBrzOJDwK6+L6krM9n5DiyfokM
         4C6tY0fsm7xsCZl890Cx+Zwr5c6jCG2cL3jPsPbsckvopQ1o4cVCi/ECm1R4sh2VzXsL
         W+8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=n1j+98FSrDpg32f5NKLaFgL1Gb2pNFMygOJPoirCPZ8=;
        b=zNjHysrf3RUZKYi8LF56iit5K0GQs1c82PNt3zSVu2mQ2xXY0CMhGCYHuyyhBPz5N8
         wyO+rMbcjv5/ErZ6xggEXtt2O1E+iJD7clGcnQrq6RhewH7D0H1ofn0o3yo8logRZ7pZ
         Gbrsel0m1+ZqDrEU/ij3IJrKw201F1O/3jkH1OGrKHJ/NfRJEIIrZ8v5Ku4Z+6N8TeGo
         c5nHcK/w8HDpW/nWeRTnUyI0/vPnW3lyESiSBZxv7UaQWkKimaCrQxPmFmR0UUWS6kWW
         gXcmanWz9gTyaYjnmO2pufRn7uPy/uVcLfmnA8ytSBCwv58W+QpShV9VqnFp/0wADZv7
         uKvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zoxgixcq;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b19sor9803255ioj.10.2019.02.28.02.35.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 02:35:12 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zoxgixcq;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=n1j+98FSrDpg32f5NKLaFgL1Gb2pNFMygOJPoirCPZ8=;
        b=ZoxgixcqqpaGMnZErw+ZFXETvifrkWXV36/v8DFcYgraF7z5rn6r1O3a0vVfoJwvYi
         iX/j0J5qJGTxUwJwf7hunG3EjLKIz2o5pSQYTa+r6+6LpQxYJszeT7IyK0LDj+6xIiOB
         odQMkL5Ikj92QCUY9XQnX9oMJwsKALnTR1z07o68ej5YMyARCPVJRJyBNFde/buqmBQ1
         1Iz393qJ2kimSySzfyn78LRlI84A1HW1oWr3UE3sfPgtT+73aFigEACeq/UbP1d5tMwm
         gdEGPCNKzTFORIHz/5czMZTz9+jh+Qks2vY2rEGyPiOJ5GVhDXJPdwthR10mOhCyKll8
         3o4A==
X-Google-Smtp-Source: APXvYqyIMk8ZnpDTyjU7ltGUPgrLHGGy1U7PRvyYe8IRIcfjek3M5QszGr8lxPVac4ySk5dmQdnjDKXqpFA3rByJV88=
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr4808892ior.11.1551350111830;
 Thu, 28 Feb 2019 02:35:11 -0800 (PST)
MIME-Version: 1.0
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com> <2cf3574c-34f9-ada8-d27c-1ed822031305@suse.cz>
In-Reply-To: <2cf3574c-34f9-ada8-d27c-1ed822031305@suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 28 Feb 2019 18:34:35 +0800
Message-ID: <CALOAHbB8veCnu2EvTMhH6dJTOcWmozSE+3sKtX9jXheFtJjQUA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, ktkhai@virtuozzo.com, 
	broonie@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 6:21 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/28/19 9:14 AM, Yafang Shao wrote:
> > In the page alloc fast path, it may do node reclaim, which may cause
> > latency spike.
> > We should add tracepoint for this event, and also mesure the latency
> > it causes.
> >
> > So bellow two tracepoints are introduced,
> >       mm_vmscan_node_reclaim_begin
> >       mm_vmscan_node_reclaim_end
> >
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
> >  mm/vmscan.c                   | 13 +++++++++++-
> >  2 files changed, 60 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index a1cb913..9310d5b 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -465,6 +465,54 @@
> >               __entry->ratio,
> >               show_reclaim_flags(__entry->reclaim_flags))
> >  );
> > +
> > +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
> > +
> > +     TP_PROTO(int nid, int order, int may_writepage,
> > +             gfp_t gfp_flags, int zid),
> > +
> > +     TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
> > +
> > +     TP_STRUCT__entry(
> > +             __field(int, nid)
> > +             __field(int, order)
> > +             __field(int, may_writepage)
>
> For node reclaim may_writepage is statically set in node_reclaim_mode,
> so I'm not sure it's worth including it.
>
> > +             __field(gfp_t, gfp_flags)
> > +             __field(int, zid)
>
> zid seems wasteful and misleading as it's simply derived by
> gfp_zone(gfp_mask), so I would drop it.
>

I agree with you that may_writepage and zid is wasteful, but I found
they are in other tracepoints in this file,
so I place them in this tracepoint as well.

Seems we'd better drop them from other tracepoints as well ?

> > +     ),
> > +
> > +     TP_fast_assign(
> > +             __entry->nid = nid;
> > +             __entry->order = order;
> > +             __entry->may_writepage = may_writepage;
> > +             __entry->gfp_flags = gfp_flags;
> > +             __entry->zid = zid;
> > +     ),
> > +
> > +     TP_printk("nid=%d zid=%d order=%d may_writepage=%d gfp_flags=%s",
> > +             __entry->nid,
> > +             __entry->zid,
> > +             __entry->order,
> > +             __entry->may_writepage,
> > +             show_gfp_flags(__entry->gfp_flags))
> > +);
> > +
> > +TRACE_EVENT(mm_vmscan_node_reclaim_end,
> > +
> > +     TP_PROTO(int result),
> > +
> > +     TP_ARGS(result),
> > +
> > +     TP_STRUCT__entry(
> > +             __field(int, result)
>
> Reporting sc.nr_reclaimed sounds more useful and in line with other
> reclaim tracepoints. Result (sc.nr_reclaimed >= nr_pages) can then be
> derived by postprocessing as the beginning tracepoint contains 'order'
> thus we know nr_pages?
>

Seems reasonable.
Will change it.

> > +     ),
> > +
> > +     TP_fast_assign(
> > +             __entry->result = result;
> > +     ),
> > +
> > +     TP_printk("result=%d", __entry->result)
> > +);
> >  #endif /* _TRACE_VMSCAN_H */
> >
> >  /* This part must be outside protection */
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ac4806f..01a0401 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -4240,6 +4240,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >               .may_swap = 1,
> >               .reclaim_idx = gfp_zone(gfp_mask),
> >       };
> > +     int result;
> > +
> > +     trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > +                                     sc.may_writepage,
> > +                                     sc.gfp_mask,
> > +                                     sc.reclaim_idx);
> >
> >       cond_resched();
> >       fs_reclaim_acquire(sc.gfp_mask);
> > @@ -4267,7 +4273,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >       current->flags &= ~PF_SWAPWRITE;
> >       memalloc_noreclaim_restore(noreclaim_flag);
> >       fs_reclaim_release(sc.gfp_mask);
> > -     return sc.nr_reclaimed >= nr_pages;
> > +
> > +     result = sc.nr_reclaimed >= nr_pages;
> > +
> > +     trace_mm_vmscan_node_reclaim_end(result);
> > +
> > +     return result;
> >  }
> >
> >  int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
> >
>

Thanks
Yafang

