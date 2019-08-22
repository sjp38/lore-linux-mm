Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05605C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF728233FE
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:18:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="YZYTmMTT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF728233FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AA096B032A; Thu, 22 Aug 2019 11:18:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 532A06B032B; Thu, 22 Aug 2019 11:18:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4498E6B032C; Thu, 22 Aug 2019 11:18:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id 24A736B032A
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:18:48 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9DAEE180AD7C1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:18:47 +0000 (UTC)
X-FDA: 75850421094.26.rake89_128607bb2993b
X-HE-Tag: rake89_128607bb2993b
X-Filterd-Recvd-Size: 5774
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:18:47 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id q22so12616358iog.4
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:18:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ucbMC5erml7tFi/vSKgs7cW+rQvFN8BeI/aLj2HiGCA=;
        b=YZYTmMTTAUoOOm7zx6b8VkiKIgXdfcyNMBNzJf1Tp1aK74EHJ6WpyOPgC8F7mErT9y
         CdjdKGw80pxYRkvnrKtEbdPeKVcUxu46hvc/UoO0h5Id0XFLumdbv99KM/mujNRftI6p
         Qvj4MPl2Usvr1Wm5DhDc4gwPnXB2xFvT4IJvx/Ygq8gTldqRtXqgxJ9W68Vrd3O8AA/a
         2DlkVF13FqTrH13tM2JPhppfC+YzRfUmpB7HEJWNIi+6RF6byJeicuzlWa6cEYCW4N3p
         F8xoBxrOBkG2uUCT0Hyas8VCHzh1gidg+7iaSJ8qn0XFKig9EwRQ4wPAjvLBEhEGaIZ8
         C87Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ucbMC5erml7tFi/vSKgs7cW+rQvFN8BeI/aLj2HiGCA=;
        b=milFcHwmETrrDQ6qPgFljFCmwoB4CCq4nnCLbB8DfRk3ujw5rhCUyb3zuL6jCTZ8R/
         kvNm0NKwgZ4UKpeSV4xhf6XBSu1X9pzT+4dNk1VWgDcYY23Ga6+cugrXu/9CNKEp12Fg
         nOyqZOaAi9I0UbiodwwnuejEVyuQqOVkO6h43WOoYUzVwxq6IOvG9b5iohY+mrYuMTV0
         1H1xjRCIKgUJx4suh2z/eiz3u+O7fKBOqWQRsB1qSdqEuMfyPktnLo3V1LpGU7SJQHxu
         UOSekNlULb9hBEXOZM7Z/MohuMOUjP+gUu/arhsgST/daJoV9wCEZ5/AtO5ltcZlu3Dl
         YGjQ==
X-Gm-Message-State: APjAAAXCAHxJUWpNG7QC3s+4u0o2mh0Uvxu38/1cJ1fMQ6biS6WSDS/2
	GA8w6jLMbvDr6BDynMum/AkK4uCRpEJYW0XRTSUvmQ==
X-Google-Smtp-Source: APXvYqzSxaxcqctxZa5RITBEENPgzu/1OGXUYLJbWIF/dhksERQTojjrUppwO1XqQ1ZQFpYDc5ZJhHQMitFVWYudvZk=
X-Received: by 2002:a02:ba91:: with SMTP id g17mr15990319jao.11.1566487126538;
 Thu, 22 Aug 2019 08:18:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190821001445.32114-1-echron@arista.com> <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <20190821064732.GW3111@dhcp22.suse.cz> <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
From: Edward Chron <echron@arista.com>
Date: Thu, 22 Aug 2019 08:18:35 -0700
Message-ID: <CAM3twVQO6DPND39RLyMGWc7FGVUkWa4j-yXsa8sfLTbiGpL+cw@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process message
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 12:19 AM David Rientjes <rientjes@google.com> wrote:
>
> On Wed, 21 Aug 2019, Michal Hocko wrote:
>
> > > vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> > > haven't left it enabled :/
> >
> > Because it generates a lot of output potentially. Think of a workload
> > with too many tasks which is not uncommon.
>
> Probably better to always print all the info for the victim so we don't
> need to duplicate everything between dump_tasks() and dump_oom_summary().
>
> Edward, how about this?

It is worth mentioning that David's suggested change, while I agree with Michal
that it should be a separate issue from updating the OOM Killed process message,
certainly has merit.  Though, it's not strictly necessary for what I
was asking for.

If you have scripts that scan your logs from OOM events, having a regular format
to OOM output makes parsing easier. With David's suggestion there would always
be a "Tasks state" section and the vm.oom_dump_tasks still works but
it just prevents
all the tasks from being dumped not from dumping the killed process.

OOM output was reorganized not that long ago as we discussed earlier to provide
improved organization of data, so this proposal would be in line with
that change.

If there is interest in this I can submit a separate patch submission.

>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -420,11 +420,17 @@ static int dump_task(struct task_struct *p, void *arg)
>   * State information includes task's pid, uid, tgid, vm size, rss,
>   * pgtables_bytes, swapents, oom_score_adj value, and name.
>   */
> -static void dump_tasks(struct oom_control *oc)
> +static void dump_tasks(struct oom_control *oc, struct task_struct *victim)
>  {
>         pr_info("Tasks state (memory values in pages):\n");
>         pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>
> +       /* If vm.oom_dump_tasks is disabled, only show the victim */
> +       if (!sysctl_oom_dump_tasks) {
> +               dump_task(victim, oc);
> +               return;
> +       }
> +
>         if (is_memcg_oom(oc))
>                 mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
>         else {
> @@ -465,8 +471,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>                 if (is_dump_unreclaim_slabs())
>                         dump_unreclaimable_slab();
>         }
> -       if (sysctl_oom_dump_tasks)
> -               dump_tasks(oc);
> +       if (p || sysctl_oom_dump_tasks)
> +               dump_tasks(oc, p);
>         if (p)
>                 dump_oom_summary(oc, p);
>  }

