Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01F40C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:47:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA68A233A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:47:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="LYNXfViS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA68A233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C4DE6B0324; Thu, 22 Aug 2019 10:47:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3756A6B0325; Thu, 22 Aug 2019 10:47:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 263C06B0326; Thu, 22 Aug 2019 10:47:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id F3A646B0324
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:47:53 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 887FE442F
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:47:53 +0000 (UTC)
X-FDA: 75850343226.20.bread34_27b7bfcd7cc00
X-HE-Tag: bread34_27b7bfcd7cc00
X-Filterd-Recvd-Size: 8072
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:47:52 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id p12so12396616iog.5
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:47:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W+PfW3oHN0X1/1L8v9CDtjGCmSfcGD06YOATXf5wVB8=;
        b=LYNXfViSeb7bFrSCrWzgiuZ9WPsUNAZeikwzUq9CRFc3JVWX1m00LX3zbz/1sj31Ba
         Pacpkc/VaV4hE/VtcvNV8S9oK7M/fd1bvVUImFA8ALptXKNwOaUGzJlcjVd9YXXhfZNZ
         k2w32JFpBalwlozpymRTzmcR2m1Xuyx/h2IVqKfqcLvl0mSvl8D8yk/7exO7k9DZ2Khg
         3g/SCRFf2JbwKmKsvWuHgL9Yn1T+ECeIFdu5YHCUABST8sRdeqQxLcNYYm/3G5BydEtK
         E0vSJQRWDmp92FMVyJfnsVs8EomSNoLs4FCnkkgl9rdho//jq2qArSHinO02fdLay5hl
         Mwgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=W+PfW3oHN0X1/1L8v9CDtjGCmSfcGD06YOATXf5wVB8=;
        b=HuBoQAf/bLiRvmCHcvq4URbFgCXUX5kTjGosoTHCAIQQY1h7Mg/ySdiJ0PM2cfDsJn
         ukS5xZRiaSRVrIHoOR9YO7RwWdM+UJZPNltgfu3EMnGKb9+6+nqt0rTT5x+1czg6qkHb
         m00RJI4if2rOwcLqzn0wQgRalQAEXue/chu0kyiB4Qdrq1d5SSjkDFyRfZm9xcd2Q/u1
         pC6ByU1TmoW6dFV7+XI/J1Q4LWRyzL6C00MLRGmSSCH2cM4eULWj+Zd8OLiZmAaQNXQC
         e+NXfsHbLR3jCeqBjFt4rSh3giegbIBUZgPGBh1KGGtos+ArxWT5GpI4le7nSviGZ5Yc
         9SDQ==
X-Gm-Message-State: APjAAAWKmuQdYobBhilgpPLxyuSXxVM50kgMZEow3NF2v/AgOy2/ugvU
	N/eUdmv9mKleSWw8fnTDRSgoVKFzbS7FFpmYAx92wg==
X-Google-Smtp-Source: APXvYqy5pkv4Sqcq3JB4UQ4qhwnxOhKMICv02hxAgpknE0Pq/j4Py7HLiZ2RXuZYIG6RgwyG6KszuFGyrXO8WzA6+2w=
X-Received: by 2002:a5e:c744:: with SMTP id g4mr2054838iop.187.1566485272069;
 Thu, 22 Aug 2019 07:47:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190821001445.32114-1-echron@arista.com> <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <20190821064732.GW3111@dhcp22.suse.cz> <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
 <CAM3twVQ4Z7dOx+bFn3O6ERstQ4wm3ojhM624NVzc=CAZw1OUUA@mail.gmail.com> <20190822071544.GC12785@dhcp22.suse.cz>
In-Reply-To: <20190822071544.GC12785@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 22 Aug 2019 07:47:40 -0700
Message-ID: <CAM3twVQatZiwhBUvo4nxc2aEixZe4jTQHyP4chTUFUsKem6JKA@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process message
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
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

On Thu, Aug 22, 2019 at 12:15 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 21-08-19 15:22:07, Edward Chron wrote:
> > On Wed, Aug 21, 2019 at 12:19 AM David Rientjes <rientjes@google.com> wrote:
> > >
> > > On Wed, 21 Aug 2019, Michal Hocko wrote:
> > >
> > > > > vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> > > > > haven't left it enabled :/
> > > >
> > > > Because it generates a lot of output potentially. Think of a workload
> > > > with too many tasks which is not uncommon.
> > >
> > > Probably better to always print all the info for the victim so we don't
> > > need to duplicate everything between dump_tasks() and dump_oom_summary().
> > >
> > > Edward, how about this?
> > >
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -420,11 +420,17 @@ static int dump_task(struct task_struct *p, void *arg)
> > >   * State information includes task's pid, uid, tgid, vm size, rss,
> > >   * pgtables_bytes, swapents, oom_score_adj value, and name.
> > >   */
> > > -static void dump_tasks(struct oom_control *oc)
> > > +static void dump_tasks(struct oom_control *oc, struct task_struct *victim)
> > >  {
> > >         pr_info("Tasks state (memory values in pages):\n");
> > >         pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> > >
> > > +       /* If vm.oom_dump_tasks is disabled, only show the victim */
> > > +       if (!sysctl_oom_dump_tasks) {
> > > +               dump_task(victim, oc);
> > > +               return;
> > > +       }
> > > +
> > >         if (is_memcg_oom(oc))
> > >                 mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
> > >         else {
> > > @@ -465,8 +471,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
> > >                 if (is_dump_unreclaim_slabs())
> > >                         dump_unreclaimable_slab();
> > >         }
> > > -       if (sysctl_oom_dump_tasks)
> > > -               dump_tasks(oc);
> > > +       if (p || sysctl_oom_dump_tasks)
> > > +               dump_tasks(oc, p);
> > >         if (p)
> > >                 dump_oom_summary(oc, p);
> > >  }
> >
> > I would be willing to accept this, though as Michal mentions in his
> > post, it would be very helpful to have the oom_score_adj on the Killed
> > process message.
> >
> > One reason for that is that the Killed process message is the one
> > message that is printed with error priority (pr_err)
> > and so that message can be filtered out and sent to notify support
> > that an OOM event occurred.
> > Putting any information that can be shared in that message is useful
> > from my experience as it the initial point of triage for an OOM event.
> > Even if the full log with per user process is available it the
> > starting point for triage for an OOM event.
> >
> > So from my perspective I would be happy having both, with David's
> > proposal providing a bit of extra information as shown here:
> >
> > Jul 21 20:07:48 linuxserver kernel: [  pid  ]   uid  tgid total_vm
> >  rss pgtables_bytes swapents oom_score_adj name
> > Jul 21 20:07:48 linuxserver kernel: [    547]     0   547    31664
> > 615             299008              0                       0
> > systemd-journal
> >
> > The OOM Killed process message will print as:
> >
> > Jul 21 20:07:48 linuxserver kernel: Out of memory: Killed process 2826
> > (oomprocs) total-vm:1056800kB, anon-rss:1052784kB, file-rss:4kB,
> > shmem-rss:0kB oom_score_adj:1000
> >
> > But if only one one output change is allowed I'd favor the Killed
> > process message since that can be singled due to it's print priority
> > and forwarded.
> >
> > By the way, right now there is redundancy in that the Killed process
> > message is printing vm, rss even if vm.oom_dump_tasks is enabled.
> > I don't see why that is a big deal.
>
> There will always be redundancy there because dump_tasks part is there
> mostly to check the oom victim decision for potential wrong/unexpected
> selection. While "killed..." message is there to inform who has been
> killed. Most people really do care about that part only.
>
> > It is very useful to have all the information that is there.
> > Wouldn't mind also having pgtables too but we would be able to get
> > that from the output of dump_task if that is enabled.
>
> I am not against adding pgrable information there. That memory is going
> to be released when the task dies.

Oh Thank-you, will include that in updated patch as it useful information.

>
> > If it is acceptable to also add the dump_task for the killed process
> > for !sysctl_oom_dump_tasks I can repost the patch including that as
> > well.
>
> Well, I would rather focus on adding the missing pieces to the killed
> task message instead.
>

Will do.

> --
> Michal Hocko
> SUSE Labs

