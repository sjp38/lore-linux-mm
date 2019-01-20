Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEC62C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 20:24:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6468A20880
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 20:24:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FvHYWjA3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6468A20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0516F8E0005; Sun, 20 Jan 2019 15:24:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F41768E0001; Sun, 20 Jan 2019 15:24:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E31428E0005; Sun, 20 Jan 2019 15:24:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9B6C8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:24:34 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id e188so1006211yba.19
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:24:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iVWug8Y2Ns5o1OPZVIkMf1S2JdPZN07bhMcpTWiOsqE=;
        b=sK/14mep3iTJMZXxqgLFU9GUjzRfC2XkZ3ixDRsi5J+cNgaDe7f+/x8HyQnRBmRmVK
         ONST+b0H8PZv4/79X8nu0cg5hAkSHgbb7v3e2YS62OYfCj3fHchW/QJkV3OxL7q8TKWU
         6LySYqfKPspOZ9yQMTlntGYtRjy4eIKU7b1fUXCIcgcY2HBG/0p10TqwQcoRAd07dQfj
         Pf/mm3eOu8G2h0Y98nj2/8qb2WttUEXDppyGEnHzd0A6Y/2NubHvGev/Mhoo9MUD+3HI
         Wa/BoyuiVMdZNlIyikDdzwb2q5bVXRk5wOvYxrvrjOlvNhATNYva98TZWfVX+hYxjFJU
         XaJA==
X-Gm-Message-State: AJcUukepVbZsJKgTTvTHeR2GmxJZnKEBwutfTPa3eQ54oHJPue3+z7sd
	HnATEDIKGOyixoqzB+RdhjOFIBIpRrq5jLUrZCkCdZyAM5UG9VIlGkXHYyRj9j4Iu+ij1j8hoTm
	IZFJMcVQnyrQEFAodOGKo2b9loNens37fzXUXAycWneKpwVQyGx259dlVoLzS/1VkIo/Mez+o+K
	qJSpJhhZjD5QweqdbO0AtWdgvzLelMQAV3F4utOxdh8fVyytj/H5DTxeP82pah4smvvlIBs/kQ4
	7yFp5AO1BnmysGIVuTqPDsE9SEvHrSS1OMNkIRxgRJy370dRlgTgTwQiz3D0obQHTVEUpStoDKg
	3EFBK4EcEWALdhvrOBxEoZeWLQnmZX4b5uHRPrt4mMOCte4jS5dXzbp7mhXKMByD3NS5MVrVwnY
	Z
X-Received: by 2002:a25:ca08:: with SMTP id a8mr5603117ybg.127.1548015874498;
        Sun, 20 Jan 2019 12:24:34 -0800 (PST)
X-Received: by 2002:a25:ca08:: with SMTP id a8mr5603102ybg.127.1548015873835;
        Sun, 20 Jan 2019 12:24:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548015873; cv=none;
        d=google.com; s=arc-20160816;
        b=Lt4F8bsBx0cAXqyYB9s0j90KqRU7yq7bRPD6d3UvhkLUBsvo0EZdfE2MzlWSowXFNK
         mKkBmtpPdp32IKT8zgt/xKJisq0NN9G6DJDqr4jqIVFR91HPAIpGqaNDd//XYtk1iTFQ
         o3DERyGNTTSDsKwhOCQqwX/3ErxU35pF93QiH8W/DkuRJx4URUEDvjH5/tTCgPuhK4gn
         vz52Xg8FrOXtHiLQmkf10zgI6k3am5qoIrs2/3TK/JnpFhLoi/FnSG2IzRTjBQP4pXyg
         lHcikQKDCkTgGm65/86RYEC9LT93O+U6dU56BNwoWyO3tQ5QPsW2B2agn/Muv/1arVg4
         I1mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iVWug8Y2Ns5o1OPZVIkMf1S2JdPZN07bhMcpTWiOsqE=;
        b=BRpnagu3bV/a9tZIqScSzukbgbMSOR/6rjhpLM2+zfgY19XbDPOkr647OykvNJL+5u
         NF/dNlzgQfsuL2zwHhNLBpzqlpkngHZy7ky0nfBXyzojXFf6XSO2GYDlYG2gLEY1YSPk
         oz3O4k1dwbAmP18aZZFUT71noISV0NlrrukMk9rahMgkvRw6ie/3bF1nrMj7u5Kcy8PF
         /oto6c9ZM3jIbe8K6SeolCDUEA+w093ww7PijaZpYwDkYBQcWXqkIK8vvKfBwmRvKqDr
         pNImDv+jUG5b4lu09HINQMT5yy+nET/I4r1Drkn/yR+YmFXdjOKvBwypgaJkWF1U5dUC
         8sFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FvHYWjA3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i133sor4319472yba.106.2019.01.20.12.24.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 12:24:33 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FvHYWjA3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iVWug8Y2Ns5o1OPZVIkMf1S2JdPZN07bhMcpTWiOsqE=;
        b=FvHYWjA385j/IdO0J937EWIjOGmT2E9/HvCkAqB997Srj0BN7ANK7ru7SqXyQDdIOZ
         46uFSw3JgtVdVpa4C/M55nkP4/N/rtsxHYc03v+ayds2x19Dhq/+GamhCjDQrI8Q0EKS
         2wf8Iqy4t7FCvBmDABUY2j8KABp3gmR/xLs0HCQic/kp/mR05NfJZEBAPabmhh9OynEO
         gvvkY+490tsUhw+hf8rmrDZGwa8WQwIi/hPv6P2MnITMHuRUCEYXeTLiykUWMzr6s2I7
         f+MLv0cqqFmzB1IrOS+MsdkNS5piEi11IRitRpfhhWWnKYrzw2YnJScyqc74wUCLql9Z
         sBig==
X-Google-Smtp-Source: ALg8bN6Q/qsc2n5y4uUzQDlUmsve6sirgrw5MTByulwHQoaWncZN+PGTc0fSmkcHbt6V/XIIw0/QoYYtLXltzIUlmBQ=
X-Received: by 2002:a25:d7c5:: with SMTP id o188mr14584562ybg.464.1548015873274;
 Sun, 20 Jan 2019 12:24:33 -0800 (PST)
MIME-Version: 1.0
References: <20190119005022.61321-1-shakeelb@google.com> <20190119070934.GD4087@dhcp22.suse.cz>
In-Reply-To: <20190119070934.GD4087@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 20 Jan 2019 12:24:22 -0800
Message-ID:
 <CALvZod7Dk-TLFHf1wi=qLAY3nv4t6grEmJkppZz=JB3GutXC+g@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190120202422.V-N55JdAphmzlV5RU356MUSNqUDEwQTkdL90NjgRMXA@z>

On Fri, Jan 18, 2019 at 11:09 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 18-01-19 16:50:22, Shakeel Butt wrote:
> [...]
> > On looking further it seems like the process selected to be oom-killed
> > has exited even before reaching read_lock(&tasklist_lock) in
> > oom_kill_process(). More specifically the tsk->usage is 1 which is due
> > to get_task_struct() in oom_evaluate_task() and the put_task_struct
> > within for_each_thread() frees the tsk and for_each_thread() tries to
> > access the tsk. The easiest fix is to do get/put across the
> > for_each_thread() on the selected task.
>
> Very well spotted! The code seems safe because we are careful to
> transfer the victim along with reference counting but I've totally
> missed that the loop itself needs a reference. It seems that this has
> been broken since the heuristic has been introduced. But I haven't
> checked it closely. I am still on vacation.
>
> > Now the next question is should we continue with the oom-kill as the
> > previously selected task has exited? However before adding more
> > complexity and heuristics, let's answer why we even look at the
> > children of oom-kill selected task?
>
> The objective was the work protection assuming that children did less
> work than their parrent. I find this argument a bit questionable because
> it highly depends a specific workload while it opens doors for
> problematic behavior at the same time. If you have a fork bomb like
> workload then it is basically hard to resolve the OOM condition as
> children have barely any memory so we keep looping killing tasks which
> will not free up much. So I am all for removing this heuristic.
>
> > The select_bad_process() has already
> > selected the worst process in the system/memcg. Due to race, the
> > selected process might not be the worst at the kill time but does that
> > matter matter?
>
> No, we don't I believe. The aim of the oom killer is to kill something.
> We will never be ideal here because this is a land of races.
>
> > The userspace can play with oom_score_adj to prefer
> > children to be killed before the parent. I looked at the history but it
> > seems like this is there before git history.
> >
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> Fixes: 5e9d834a0e0c ("oom: sacrifice child with highest badness score for parent")
> Cc: stable
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> Thanks!

Thanks for the review. I will keep this for the stable branches and
for the next release I will remove this whole children selection
heuristic.

Shakeel

> > ---
> >  mm/oom_kill.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> >
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 0930b4365be7..1a007dae1e8f 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -981,6 +981,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >        * still freeing memory.
> >        */
> >       read_lock(&tasklist_lock);
> > +
> > +     /*
> > +      * The task 'p' might have already exited before reaching here. The
> > +      * put_task_struct() will free task_struct 'p' while the loop still try
> > +      * to access the field of 'p', so, get an extra reference.
> > +      */
> > +     get_task_struct(p);
> >       for_each_thread(p, t) {
> >               list_for_each_entry(child, &t->children, sibling) {
> >                       unsigned int child_points;
> > @@ -1000,6 +1007,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >                       }
> >               }
> >       }
> > +     put_task_struct(p);
> >       read_unlock(&tasklist_lock);
> >
> >       /*
> > --
> > 2.20.1.321.g9e740568ce-goog
>
> --
> Michal Hocko
> SUSE Labs

