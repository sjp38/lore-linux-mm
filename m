Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDFC0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:32:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B32C2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:32:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TYwRGtVr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B32C2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B4468E0003; Tue, 26 Feb 2019 08:32:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1643E8E0001; Tue, 26 Feb 2019 08:32:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 053138E0003; Tue, 26 Feb 2019 08:32:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D3DF68E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:32:43 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id k24so10302415ioa.18
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:32:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QIlceVK6uCEp7d4NpkPtAYGnz6eZLREyR/3l0EGyiG0=;
        b=R+vmblmTeRLmhRRrv4YrKE65g5YOGr95TTqYuuCTFs5t0QHeoBMkPiyy9Hp1B7gAYW
         huS9IKC+LEFZHzxwUVZ7AAi/uKae000v+NFcgcgBHghe5rucMR+EAfqadbStRHH4YDo7
         Q4ylI2FbJEnZzMd6xH+CrvWuzYv+YV3iH2KB2rBe1m7Bw/NteDWYllbFjkjjfLFfWIfX
         9tg2lHTeA//AI6ZLknTvm1HFvcCLJjscItnB5qPLGDkAJARU2c3eTjcExo7plOPUCTAy
         iIMIHthB/J+DppZ3WGQYkDu91BY0R3ZJRWwZbltkHtdQ8QEgNu/+w16stgrDoCATCQXw
         iQOA==
X-Gm-Message-State: AHQUAuYVMAebQtX2e+UZ+0AIzIjhc6AZyMPjE0DcD3ws6DFhKFtrzlV6
	bd4nfvM+vRpkL/FL1u/ktUjjo3ykjIHt/Lh2T1ZeoTHdHda6S5apF7l/68fSb0Z+Z14t/oRp4S+
	5sG7LrN/UImWKb2dq2zuwTphhsFYgQFmOyoxQLA4VeQ5fzPXh6MkuKY3LYFOEaXKvmGbaP/K0gN
	MpAprjRJDyaN1CWbE6JDbAa7RFkwiNkaf4mm0fWUcQd9fbWpHq6L477KZf4rhOPPXABfbiypIYr
	Ha9cSDHHr0+r9v/t05gcllOWQj9TOVK/vCtkKj8tRF8j2PkOI4BCGDViJfbHN3HdxlaEenxUGSe
	FjNiF8ULHlqIm4KCffqtmuLcuECL0lbDiGIsXHdt/yFzl5QgHapXxIydXYLaGQWF/8hu0CtvXtL
	B
X-Received: by 2002:a5e:d819:: with SMTP id l25mr11148833iok.27.1551187963547;
        Tue, 26 Feb 2019 05:32:43 -0800 (PST)
X-Received: by 2002:a5e:d819:: with SMTP id l25mr11148798iok.27.1551187962751;
        Tue, 26 Feb 2019 05:32:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551187962; cv=none;
        d=google.com; s=arc-20160816;
        b=nrWN4pTw6yFvQCiIFNULsAXvk8fKMNZLU6dYjnQh4c0MlDkHTaTlhvTAXJOdM5Z+dS
         8iGcoq/q76SO7deF928voMyKQI6mHcGRP6O8HQSWcJGI1vkv5SA0uW6g/JQ90G/vQmfG
         zbL7gtdtKSwsG6IZVjHwRXlf1lnMfhCUHkqb9AWeUe3n+ancPT+Je1RUVRQZWVHkO70p
         K75zze/o0e/HWjRtmvOxyUYrZJ2Yavzv1AHJpvfGbHgz3b7rG5rR28Ujs1BzQtcBLzGS
         yzH7JKBX5lQwsU1AlUDd0qSaQHlWcBQOpqunaJkk1a8Z70QHu7UpbdCeRJoZ3E9KeAgo
         XYEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QIlceVK6uCEp7d4NpkPtAYGnz6eZLREyR/3l0EGyiG0=;
        b=jT0OVGe37m0VcVZwVc7/hYF2Lbt0DOQVhxr4SotaO5Howxqpz7GF9CwlUdaxYksRUJ
         1M3D+QxKSz9r2fqbPvn27UqH+G4udClsBShwGawSLG7vAAGgs2g7w7Lj1qjm4esvx2yg
         tm13Cd/b0dGMKmvFh7Na4gq64Nb58G5SwnTdK7rFZrqxdaHjrT7chQK8mBzrLSHaBZBy
         n5v6dnq9NQOLfbcNGSyL9qOeMHpGmRudOazDW9XZtPA5Qv5ZHsMsFS7SVqIkjCpcbB9P
         fM7LJm1wZPO+QfLCdSWZu4KLmciuzkxdTz1TuSCx7BPVl3JrwKBl0ofL2zyuZdrmvZL2
         jDUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TYwRGtVr;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor30310315jab.5.2019.02.26.05.32.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 05:32:42 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TYwRGtVr;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QIlceVK6uCEp7d4NpkPtAYGnz6eZLREyR/3l0EGyiG0=;
        b=TYwRGtVrpMYGuw8nlMX4r9bP0d0kRLGXYTdn9qsq/mA+TuqsoR047mWaj4mT+PrIaU
         W1VumQIGERi39Af3lRLGg58nD35tnvqofEHhL0G/OWMRbaLppyW9RMAZJdlO/Ztq87So
         TcFb9J/9CIdQ8RqUsaqvs3Y+pMmyClyG0e+yd6i2P2o39BlXA1/PEkLDIjbvZVKUKcr/
         QoxWeX65MKqKt+njFD5cf3xmmxi0Tsi7Bf7QgF24jUdbG3Ym2B7+xGsgaKgdaUEhN0W0
         0aat+aMnFTg1JLoBnE3t0OBR4DzEQDxrYyHdudcKpvEnblt099mq0XQ9RczcD2yvvOJR
         8goQ==
X-Google-Smtp-Source: AHgI3IZKvpwZpIZFQyhB6NhrySDaoiiQA9PwZ422EoH3eqvtK0k+LlOkTai9PmYpx1VObIhdTIbQVRhbN1DGsLZY/dE=
X-Received: by 2002:a02:ec4:: with SMTP id 187mr11974439jae.11.1551187962466;
 Tue, 26 Feb 2019 05:32:42 -0800 (PST)
MIME-Version: 1.0
References: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com> <8622dd4e-6341-1ea2-0e26-ed7f6b2aaec4@suse.cz>
In-Reply-To: <8622dd4e-6341-1ea2-0e26-ed7f6b2aaec4@suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 26 Feb 2019 21:32:08 +0800
Message-ID: <CALOAHbBBKbJqD4kGQzescyvEnzfxmZyNPvy-wEsGHLEt+KQtSA@mail.gmail.com>
Subject: Re: [PATCH] mm: compaction: remove unnecessary CONFIG_COMPACTION
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 8:32 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/26/19 7:19 AM, Yafang Shao wrote:
> > The file trace/events/compaction.h is included only when
> > CONFIG_COMPACTION is defined, so it is unnecessary to use
> > CONFIG_COMPACTION again in this file.
>
> Are you sure? What about CONFIG_CMA?
>

Oops.
My bad. Sorry about the noise.

> #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>
> #define CREATE_TRACE_POINTS
> #include <trace/events/compaction.h>
>
>
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  include/trace/events/compaction.h | 4 ----
> >  1 file changed, 4 deletions(-)
> >
> > diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> > index 6074eff..06fb680 100644
> > --- a/include/trace/events/compaction.h
> > +++ b/include/trace/events/compaction.h
> > @@ -132,7 +132,6 @@
> >               __entry->sync ? "sync" : "async")
> >  );
> >
> > -#ifdef CONFIG_COMPACTION
> >  TRACE_EVENT(mm_compaction_end,
> >       TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
> >               unsigned long free_pfn, unsigned long zone_end, bool sync,
> > @@ -166,7 +165,6 @@
> >               __entry->sync ? "sync" : "async",
> >               __print_symbolic(__entry->status, COMPACTION_STATUS))
> >  );
> > -#endif
> >
> >  TRACE_EVENT(mm_compaction_try_to_compact_pages,
> >
> > @@ -195,7 +193,6 @@
> >               __entry->prio)
> >  );
> >
> > -#ifdef CONFIG_COMPACTION
> >  DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
> >
> >       TP_PROTO(struct zone *zone,
> > @@ -296,7 +293,6 @@
> >
> >       TP_ARGS(zone, order)
> >  );
> > -#endif
> >
> >  TRACE_EVENT(mm_compaction_kcompactd_sleep,
> >
> >
>

