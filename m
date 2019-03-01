Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B15C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 08:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E4FB2085A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 08:39:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sG3dZWqg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E4FB2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C038D8E0003; Fri,  1 Mar 2019 03:39:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB2C18E0001; Fri,  1 Mar 2019 03:39:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7A488E0003; Fri,  1 Mar 2019 03:39:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB7C8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 03:39:05 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id w8so2233204lfc.21
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 00:39:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qnyFKua0Ma32Sx5B0QpXHBKkuP+Q5Kg1stVhtIDMIX8=;
        b=cgVSQRWeUpkHEbUpKFd9fgCNQAAmlqhXyfEsgg0OMz7vbfDe0gLsc/N4g9ddvymCkS
         B9EkNGZzlobk+wiGELZg53Hlf+eKLbKpCFJu+KhXdrJTsbiE+C1+bj/DKY3keOHZk12z
         98xp1pKWWs8aDTIsWhzg+IQF4vBU6lk/FVCwvXZUFpibmW3PbaeiSy+iljHGhIbDrrLy
         9GF9qwO4j8Er95o2Wb5rPzceuETk9KOv9qXPy0Kly6bWikqeGrSYb4wOAR7FNhhfPz88
         7C9ZDJGn0YBqWuU9WcgSiNF7QDmK2iwUJEwgggXyL76l7JzY9KzQ787IsHwZObVXd9Mb
         +1hA==
X-Gm-Message-State: APjAAAU+j2RL7Nw0alBOjIIR0qqcIYFdH4/alv1O/whYlF5VxCn5auka
	f7/XjneVwcnsOdykc6sHNbnob5n8xh+4qjWFB4908gNkiQIHeKoNESjhYGE0/29neDwNb6J/VzA
	9ASGEWA5RXQ9n04wgFZqsQjUDDEHbRNrLUWf20q42kxLrwEPDa+Ur+v8Ibl3lPZiGbO9FUYIVl2
	9A9cnKhpxw5UcHPIIAgRh7Qkh7sNtiz0ZqvaEkBfPS9qQ4GOVIRlZKbFjsPrA0RecigI4+SfhqT
	lFPRXNy8HAEGVJMo8CUUvLH+Eg5YqPxbgXyjogw6soCy/o0xAvV2K4NJSy04CAyYm+zcOeXyVot
	JZ1tCVzdgNgBtHs9THV0L1opuq5FkFjH2nXSrjEpSBwSrKTnmAIrlNPGoL6FDEmyoSjlKsDHp25
	z
X-Received: by 2002:a19:2105:: with SMTP id h5mr2218395lfh.17.1551429544337;
        Fri, 01 Mar 2019 00:39:04 -0800 (PST)
X-Received: by 2002:a19:2105:: with SMTP id h5mr2218347lfh.17.1551429543300;
        Fri, 01 Mar 2019 00:39:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551429543; cv=none;
        d=google.com; s=arc-20160816;
        b=MwzWxXUDs3G6KXC4tUBnjns/PvHO7uOjKcSnEYLh4aZPnRNvLlJHkzV78ilvigS+Sx
         9s7u4oiLB4Z5Csxg6HH5Umh5Fr2qNMaHXB20WV7kcaCYmc6MjayAA/b0rB+9iSc2Dk8f
         jXa0gT6YzaKw5NIVDN6kzdrYL7SzO/SUgf5OI5Esc8lWs8p3qq+w3xN0iOdWiIMBjHsR
         e5nrGqtROlZRx3L4kBIZVo4re8Av6TIU1B4QpXsAl4DS2kF4G0Xebhrc+Sj2QV4Yeu7e
         UbAqjopPo/TMHzrNuMYRuwIREDApnTl9hHTdQTEYqLXVoHJqVKjjNzZLUJClEq/Hevm2
         t3/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qnyFKua0Ma32Sx5B0QpXHBKkuP+Q5Kg1stVhtIDMIX8=;
        b=XLdzFQy52W5OU5l6wCGhF8ZeDYoW8hn8QJAoGC8ivagsKYgmeQIGP/0hAa5FHWDAc5
         Blj9kYz+o43iRNa7hAm22jSd5AJjaLOpVumUIsvZOzAxbghbjCZaJedJGs0geVZNBpM1
         GtfpBDzvALdVfrD5aB9JB5rWKC6aAe+OvC6EgzlD4C1KW2T+FvsjY4cNqKFOjmlgNS27
         pj7vglGOnOtd9QMdcu+Pts5bYq2ARlD4VZUAbV0aRqlAvGdzqkbZfnLlDhF/g71lAXRo
         xtHOr8ob5enDJl6v056xE5KVoXo74cJXw3OVu3rJi88WRy67zelXmNbXpi8ROEfOOog+
         0pxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sG3dZWqg;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b141sor543706lfg.24.2019.03.01.00.39.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 00:39:03 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sG3dZWqg;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qnyFKua0Ma32Sx5B0QpXHBKkuP+Q5Kg1stVhtIDMIX8=;
        b=sG3dZWqgA5FRR3DHZ21C2LtXUuYzUbMwmm40oOBmGxStSvL9weTGNbaiKykOuPAiVK
         1Hf7pzcpFz0Hacot/mz3PFr3tmM+afJ4FnE6mDxgzMp8CW9hzV4LYlgIqxa0r55i65P2
         TOcRqJ3/LGPJmAoCJcuqytQ9iXbcN7NbLENL2ugxRyHVGj5MUqUu1+wphbzsXfTJpkqz
         02mOx+pa4iFrGsCsf5/DUEPYnN8fL8eEDiDghOtjBoGUm46D0m3UduPIrfvoUwOkCeDL
         8SbeMq1k4cMEWrfPQWZJaVAE49CMpgEKiIzwaTXSV/q755DNphwffmzIJKKAvvVYn68W
         0zwg==
X-Google-Smtp-Source: APXvYqy5PcgDQYb1oYkgk2pPVnrAPHJ6sZPWqn5OfCb3xjll6lhXw3UFaD6I9nG2MYc8DKEueHBjx++6JBbPWVnh6dw=
X-Received: by 2002:a19:c616:: with SMTP id w22mr2281551lff.31.1551429542532;
 Fri, 01 Mar 2019 00:39:02 -0800 (PST)
MIME-Version: 1.0
References: <1551421452-5385-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1551421452-5385-1-git-send-email-laoar.shao@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 1 Mar 2019 14:08:50 +0530
Message-ID: <CAFqt6zZAjt2gmYPT_KPosfeDKnWNeBJoveKEytOJZeDHh=ZjzA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: vmscan: add tracepoints for node reclaim
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-kernel@vger.kernel.org, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 1, 2019 at 11:54 AM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> In the page alloc fast path, it may do node reclaim, which may cause
> latency spike.
> We should add tracepoint for this event, and also measure the latency
> it causes.
>
> So bellow two tracepoints are introduced,
>         mm_vmscan_node_reclaim_begin
>         mm_vmscan_node_reclaim_end
>
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
(for the comment on v1).

> ---
>  include/trace/events/vmscan.h | 32 ++++++++++++++++++++++++++++++++
>  mm/vmscan.c                   |  6 ++++++
>  2 files changed, 38 insertions(+)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index a1cb913..c1ddf28 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -465,6 +465,38 @@
>                 __entry->ratio,
>                 show_reclaim_flags(__entry->reclaim_flags))
>  );
> +
> +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
> +
> +       TP_PROTO(int nid, int order, gfp_t gfp_flags),
> +
> +       TP_ARGS(nid, order, gfp_flags),
> +
> +       TP_STRUCT__entry(
> +               __field(int, nid)
> +               __field(int, order)
> +               __field(gfp_t, gfp_flags)
> +       ),
> +
> +       TP_fast_assign(
> +               __entry->nid = nid;
> +               __entry->order = order;
> +               __entry->gfp_flags = gfp_flags;
> +       ),
> +
> +       TP_printk("nid=%d order=%d gfp_flags=%s",
> +               __entry->nid,
> +               __entry->order,
> +               show_gfp_flags(__entry->gfp_flags))
> +);
> +
> +DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_node_reclaim_end,
> +
> +       TP_PROTO(unsigned long nr_reclaimed),
> +
> +       TP_ARGS(nr_reclaimed)
> +);
> +
>  #endif /* _TRACE_VMSCAN_H */
>
>  /* This part must be outside protection */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ac4806f..2bee5d1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4241,6 +4241,9 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>                 .reclaim_idx = gfp_zone(gfp_mask),
>         };
>
> +       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> +                                          sc.gfp_mask);
> +
>         cond_resched();
>         fs_reclaim_acquire(sc.gfp_mask);
>         /*
> @@ -4267,6 +4270,9 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>         current->flags &= ~PF_SWAPWRITE;
>         memalloc_noreclaim_restore(noreclaim_flag);
>         fs_reclaim_release(sc.gfp_mask);
> +
> +       trace_mm_vmscan_node_reclaim_end(sc.nr_reclaimed);
> +
>         return sc.nr_reclaimed >= nr_pages;
>  }
>
> --
> 1.8.3.1
>

