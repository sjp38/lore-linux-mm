Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCD23C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:48:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9166820863
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:48:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DYbfUmrC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9166820863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B27F6B0006; Mon, 17 Jun 2019 12:48:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 164AF8E0002; Mon, 17 Jun 2019 12:48:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 053348E0001; Mon, 17 Jun 2019 12:48:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB0C46B0006
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:48:55 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id e7so11204355ybk.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:48:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+bhc7wfVjCBaM/En8KIXc3jvZNzrMiSbZDMErO7mmcg=;
        b=X1hQm7n3o0MTLVB1KsNebB50bRw4zXLsB6Qjg1jD0sxxYYkhgbi9Oy7gzF36B6Gc4w
         fd7u6umYINpZPa8ydDAXGZHV6yagEgmgVV4JFgmy8cNbfsYa1jhiiVh+tn2zAjjcwxyH
         6kAFYbbE/oHUfEy+WGxz9V7sfLMWjTEvRehlXuxHrtkSo4kV4IrDd+o01y1c2c6+hUHO
         W7/JA3SyPImLkAv7R9Rg5pBPzZNh8LCye2zHMN3YBbomd/H9m4nM7oyReX7l0WDk6+Tg
         sJs2lDm4sjb+vipio37LBh5LTd6CzEFra3tvSrzdHkXvDQska4+yXiWtMgfk4HiFZqmL
         W1cA==
X-Gm-Message-State: APjAAAVs1juacqy18MKFBqmv9enmGwcvp8oCQQv1F0r3A7oJn8KxhDHN
	s03BsODnp28s/IOavFAqDuM/CCQB/jbsYx6JwcA8n/G7hLcGWSPuRG9xzxzDVIioTwPu3JIOJcF
	vpRH+zM491SyPrTuvb1EQnxfz/+DAvr+6tGsYXafl7KELZPe2sz/9v46lDF1hiIyZSQ==
X-Received: by 2002:a0d:d714:: with SMTP id z20mr35666965ywd.23.1560790135534;
        Mon, 17 Jun 2019 09:48:55 -0700 (PDT)
X-Received: by 2002:a0d:d714:: with SMTP id z20mr35666941ywd.23.1560790134957;
        Mon, 17 Jun 2019 09:48:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560790134; cv=none;
        d=google.com; s=arc-20160816;
        b=BLsU2nginXLKcA0jHPElSOsAbrTVZEW+6hPRjAWPuUifqZA2cYvg7Ux3DHrrlUQeaF
         Q/qfnOsizLWmMpZH1mh7DCWlI7VKXc1yr3zu5mOpND6Imr4yJUUN+6nzlYUZMAT8Sa1+
         d12vX3MgGq6QRzWvvz9LZJkmU3TKcSJ5c/w9isD+/OZMzvNUphFj2mWfbHHuAXJ1kpJC
         dE90bTBmW9+pohuPiy1yqLtb31638kCsg828mRcoweHR0zDeeBL+zfcJZwFREZ4oxYI/
         JlZGwKFSGbNkss7EtPCra/D50adCG/VRI2xSHY7MG9zDVTc3AOWAdZI27r3tOzrrP9cw
         wbIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+bhc7wfVjCBaM/En8KIXc3jvZNzrMiSbZDMErO7mmcg=;
        b=qcvMaLYnw7zso4d4uiuYbbfByTU7m+Ht7/CamhIwI0bffzsOF0S4eviTWTT4fzmIc+
         1TDUQm8J+MOd6IQmD8IG2R9PHJkoFe7WjiZLYGVXPLHHFlK/31etGlGUTWQ5cvS4A2Be
         PX/UkiVUE2Ak9kaLdd3vtM+coYkWVZxrreeDcQ6b8bIdTWbywfnFIhu83R1/04VwVQIl
         TkPvOQVky3D9MxBSQcVLeiRVHCrNO8e3B8YN3KGooLAJ6YFVqi4evbFcrMnj0HKf1/M3
         WaGZ01UYJfzWFuDQ8mzymRGbiz7Ob5iDZr46rRlc06W/LcY+uNLHzTh12CRuMI7TFwPp
         XrSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DYbfUmrC;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y196sor6431082ywy.56.2019.06.17.09.48.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 09:48:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DYbfUmrC;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+bhc7wfVjCBaM/En8KIXc3jvZNzrMiSbZDMErO7mmcg=;
        b=DYbfUmrCCAumnmXWODR8+LTnOQ7KCdpvfaHsby+TAizkhkgf9X+hDwVKW4YCRvdsbR
         /DOd5z4sNTjXhhHg4CBJHxUJprspmaW8XaWIiWkX+EV8vLcn2YwQSz+9l1BWRwYW+73b
         sRLre+0lZ4TKnygun0iG/ayZWy5ATKzXzNZl5MrbxQC3DEEIjRdnA13dv/ZlgoicmAOp
         g+jvdpAKS2ONslZ6WLqsoHuzSs2omaxjORyd3O7XTFtCOfvPuIEcfVq6Aw0u+QZRs2wk
         T+cp2SBxHX7+kuygOvMGZO3uv0/dBlh/APwxh1cjz+fNoqmHVtoZvU29KFhUYSks2J70
         GFHA==
X-Google-Smtp-Source: APXvYqxYDlg2DGtdAFSTrNecvf6mKBN+e0hfaf7Tt/m0UWAiagrxescZo68t6wSXRTD7aC9x4EqbsMND7aHUQSudaIQ=
X-Received: by 2002:a81:a55:: with SMTP id 82mr29118544ywk.205.1560790134326;
 Mon, 17 Jun 2019 09:48:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190617155954.155791-1-shakeelb@google.com> <20190617161702.GE1492@dhcp22.suse.cz>
In-Reply-To: <20190617161702.GE1492@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 17 Jun 2019 09:48:42 -0700
Message-ID: <CALvZod6mO0-nK+aVP+-neFt3B95ztNGQMXLYFZ7oEeasTsXRCA@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: fix oom_unkillable_task for memcg OOMs
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 9:17 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 17-06-19 08:59:54, Shakeel Butt wrote:
> > Currently oom_unkillable_task() checks mems_allowed even for memcg OOMs
> > which does not make sense as memcg OOMs can not be triggered due to
> > numa constraints. Fixing that.
> >
> > Also if memcg is given, oom_unkillable_task() will check the task's
> > memcg membership as well to detect oom killability. However all the
> > memcg related code paths leading to oom_unkillable_task(), other than
> > dump_tasks(), come through mem_cgroup_scan_tasks() which traverses
> > tasks through memcgs. Once dump_tasks() is converted to use
> > mem_cgroup_scan_tasks(), there is no need to do memcg membership check
> > in oom_unkillable_task().
>
> I think this patch just does too much in one go. Could you split out
> the dump_tasks part and the oom_unkillable_task parts into two patches
> please? It should be slightly easier to review.
>

Yes, will do in v2.

> [...]
> > +static bool oom_unkillable_task(struct task_struct *p, struct oom_control *oc)
> >  {
> >       if (is_global_init(p))
> >               return true;
> >       if (p->flags & PF_KTHREAD)
> >               return true;
> > +     if (!oc)
> > +             return false;
>
> Bah, this is just too ugly. AFAICS this is only because oom_score still
> uses oom_unkillable_task which is kinda dubious, no? While you are
> touching this code, can we remove this part as well? I would be really
> surprised if any code really depends on ineligible tasks reporting 0
> oom_score.

I think it is safer to just localize the is_global_init() and
PF_KTHREAD checks in oom_badness() instead of invoking
oom_unkillable_task(). Also I think cpuset_mems_allowed_intersects()
check from /proc/[pid]/oom_score is unintentional.

Shakeel

