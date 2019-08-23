Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5C16C3A5A1
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 01:27:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40C10233FD
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 01:26:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="snA1OU5i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40C10233FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876556B0373; Thu, 22 Aug 2019 21:26:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 827596B0375; Thu, 22 Aug 2019 21:26:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 715976B0376; Thu, 22 Aug 2019 21:26:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id 511346B0373
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 21:26:59 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DFD71180AD7C1
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 01:26:58 +0000 (UTC)
X-FDA: 75851953716.07.salt13_5a01e9c5ffd23
X-HE-Tag: salt13_5a01e9c5ffd23
X-Filterd-Recvd-Size: 6928
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 01:26:58 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id z3so16360245iog.0
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 18:26:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=y0dNZ1RUXIIxYGPngKWbDG6PCMhShOuu+VIqzBo7m6E=;
        b=snA1OU5iZEy6DYbwS1Hu21so5ikk9k4D0pgXvhiIrZiyr1QJcgtwG+mIY8AdJo2VR/
         SdSGFBpaL4RI5xppo5cVubJw0sx7H/ejKVUtN8Os0SNAwWudD7hY08xDSnl+vlfuhAn+
         E7z70FQMuv4JlJI7+l17i7xMFOmm3PeOfQTCMVC0KH661WjsSDe/kYBTD16i16BVHNgP
         +z7PNkclhfT3Wr/Jf3MlT4+PEL2rPqJoBiY7cpseY1WZMqNfVF9V8RjVkxuyLKMosArw
         WAmtg2UE1HnlJLr3DbIyGm668YGccyJfcA4Vw5I/9pU3xnEQGFnRctSdISoxbP+7rwaY
         QO9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=y0dNZ1RUXIIxYGPngKWbDG6PCMhShOuu+VIqzBo7m6E=;
        b=BHmHIFLRo4bXGTZUr/nO8HWpMcY9mEKMX3knTfvkARRYLU85syarW/Dn3LubqcrRwU
         29atBtHBR3i4OexTswHvmX4Asq4jf7E5JSaMdtjvZu0XRvwetVEu1jPX25R6bMGE77aO
         9rzX/zGObnKmnFtYXknTx9VcOUPOsP2tjPF24zPiyTJKIcFVhwFI5AZTUaIsbSndBnPq
         w87cTxEsCBzambsqsyU9cjQO+NtQRievUZk7OVOSPtIVKZcwH3YLY/8qhwxvS+3I6EQA
         eGjb8MYJOLkQ0N2EZAi6JpV/faVCo4woTrtHgRJ7SYTi7lbrzqaJOKbK9hpLLwSMbuv0
         Z3HA==
X-Gm-Message-State: APjAAAXlzk4IG4o924R9fOO9yXLtiy8qIrxRPemqWV9GCn8bNzJBPRA8
	Jlx7MvOjYnwHouj2sHfFSA/hVvbC5wd/DUpElWQ=
X-Google-Smtp-Source: APXvYqylcT5YPjhIc5ETBbwNSXD3JGIGH+MIgKjPJ92u20Dw4Yg2HGGxtWssuylTPDmtZ1f1ZxhWYFmTYLWc+SugQEA=
X-Received: by 2002:a05:6602:224a:: with SMTP id o10mr3609099ioo.44.1566523617780;
 Thu, 22 Aug 2019 18:26:57 -0700 (PDT)
MIME-Version: 1.0
References: <1566464189-1631-1-git-send-email-laoar.shao@gmail.com>
 <20190822091902.GG12785@dhcp22.suse.cz> <CALOAHbAOH+Y+sN3ynAiBDm=JWrm4XpyUm8s3r9G=Oz4b0iNvCA@mail.gmail.com>
 <20190822105918.GH12785@dhcp22.suse.cz> <20190822224654.GA27164@tower.DHCP.thefacebook.com>
In-Reply-To: <20190822224654.GA27164@tower.DHCP.thefacebook.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 23 Aug 2019 09:26:21 +0800
Message-ID: <CALOAHbBD2XaWQwrrd5xm4gCqE=Zffoy4FeU5zg6SSk2+O=9UTA@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: introduce per memcg oom_score_adj
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 6:47 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Thu, Aug 22, 2019 at 12:59:18PM +0200, Michal Hocko wrote:
> > On Thu 22-08-19 17:34:54, Yafang Shao wrote:
> > > On Thu, Aug 22, 2019 at 5:19 PM Michal Hocko <mhocko@suse.com> wrote:
> > > >
> > > > On Thu 22-08-19 04:56:29, Yafang Shao wrote:
> > > > > - Why we need a per memcg oom_score_adj setting ?
> > > > > This is easy to deploy and very convenient for container.
> > > > > When we use container, we always treat memcg as a whole, if we have a per
> > > > > memcg oom_score_adj setting we don't need to set it process by process.
> > > >
> > > > Why cannot an initial process in the cgroup set the oom_score_adj and
> > > > other processes just inherit it from there? This sounds trivial to do
> > > > with a startup script.
> > > >
> > >
> > > That is what we used to do before.
> > > But it can't apply to the running containers.
> > >
> > >
> > > > > It will make the user exhausted to set it to all processes in a memcg.
> > > >
> > > > Then let's have scripts to set it as they are less prone to exhaustion
> > > > ;)
> > >
> > > That is not easy to deploy it to the production environment.
> >
> > What is hard about a simple loop over tasklist exported by cgroup and
> > apply a value to oom_score_adj?
> >
> > [...]
> >
> > > > Besides that. What is the hierarchical semantic? Say you have hierarchy
> > > >         A (oom_score_adj = 1000)
> > > >          \
> > > >           B (oom_score_adj = 500)
> > > >            \
> > > >             C (oom_score_adj = -1000)
> > > >
> > > > put the above summing up aside for now and just focus on the memcg
> > > > adjusting?
> > >
> > > I think that there's no conflict between children's oom_score_adj,
> > > that is different with memory.max.
> > > So it is not neccessary to consider the parent's oom_sore_adj.
> >
> > Each exported cgroup tuning _has_ to be hierarchical so that an admin
> > can override children setting in order to safely delegate the
> > configuration.
>
> +1
>
> >
> > Last but not least, oom_score_adj has proven to be a terrible interface
> > that is essentially close to unusable to anything outside of extreme
> > values (-1000 and very arguably 1000). Making it cgroup aware without
> > changing oom victim selection to consider cgroup as a whole will also be
> > a pain so I am afraid that this is a dead end path.
> >
> > We can discuss cgroup aware oom victim selection for sure and there are
> > certainly reasonable usecases to back that functionality. Please refer
> > to discussion from 2017/2018 (dubbed as "cgroup-aware OOM killer"). But
> > be warned this is a tricky area and there was a fundamental disagreement
> > on how things should be classified without a clear way to reach
> > consensus. What we have right now is the only agreement we could reach.
> > It is likely possible that the only more clever cgroup aware oom
> > selection has to be implemented in the userspace with an understanding
> > of the specific workload.
>
> I think the agreement is that the main goal of the kernel OOM killer is to
> prevent different memory dead- and live-lock scenarios.

I argree with you that this is the most improtant thing in OOM, and
then we should consider OOM QoS.

> And everything
> that involves policies which define which workloads are preferable over
> others should be kept in userspace.
>

I think it would be better if the kernel could provide some HOOKs to
adjust the OOM QoS.
Something like ebpf or some interfaces like memory.oom.score_adj or
something else.

> So the biggest issue of the kernel OOM killer right now is that it often kicks
> in too late, if at all (which has been discussed recently). And it looks like
> the best answer now is PSI. So I'd really look into that direction to enhance
> it.
>

Agreed.
The kernel OOM killer kicks in only when there's almost no available
memory, that may cause system hang.

Thanks
Yafang

