Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7B85C3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:16:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A3E22070B
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:16:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ei6ZMKFL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A3E22070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1015F6B0007; Mon, 19 Aug 2019 21:16:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B32D6B0008; Mon, 19 Aug 2019 21:16:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE4106B000A; Mon, 19 Aug 2019 21:16:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id CEF556B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:16:38 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8DC5740E6
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:16:38 +0000 (UTC)
X-FDA: 75841041276.27.peace06_742611fccdf27
X-HE-Tag: peace06_742611fccdf27
X-Filterd-Recvd-Size: 6430
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:16:38 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id q22so8602740iog.4
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:16:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0Dsoa8pkI2Xu6W+8rPAymR0htOwue4tUKHVfA28A/NY=;
        b=Ei6ZMKFLyA1ACxo7AlgZT3jgCzdNPlcSE6BmWw9GYnhreJAzPsY92bF8xgJU/+ceJk
         TWjYZZA/FpHT1i3z9Nir0uBZWDJO8Greq8V1WeRTBgicRaYnJtVjb51lOyUMRjZRnilM
         bpl/zeeh7EoEhwrdoAI/+QNFuA8cLATcPzfYuP9+AbUteia1Kin+0Aw4ln/1IihrDaF8
         w7dCDvQwBihhL+Q3UnLx68gZtMPkr7yvZ94/lJtpZvMpDA2RZ1MQ5D3llGCftkyDKaUD
         +ZLMLPTsc/5DLxRz3v3RKiNiooScBJQ2kQXJQ0IUKdZidsRAi0vVYDbZHNsXhSrd6qxe
         haxA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=0Dsoa8pkI2Xu6W+8rPAymR0htOwue4tUKHVfA28A/NY=;
        b=tqnxtLzFdbaKylDSSqSv+ARworQF8EgBpuL1X22NK/XNm6Nd+DoDbErzArTzcvm4Zi
         Q0s0eXfvKBuvH+BAeinzGD1caMZAmNaI5FI3Vvt7ARpDVbuRZ05mrJrRSXl9SMwi+lvB
         JPj/GTFwpy0AI/9i6l4l1GrteUQwSTZlxbUyObZQp0h2iOij4bRAFTkAB5XpqG0Euaa3
         HHW4ksvJsTfGwmcMBF/TYRaZMj6++4zqAHHcH40K6OOtAd8+0fqEK97f2G2sO1h5feaL
         yed/dhQ2nosYmJMMOnZ2ISaAssmIpO0kcQ5AiRJ8j2ch4CYAafIINEC5GZjqX2UAbwk5
         3EcQ==
X-Gm-Message-State: APjAAAUMy3E0lzdz6aY03DFqsxeLqTn7/fAu9iIG5aLzn2nU1Rsb8WSF
	r1HyfEGpLb2YVFyaIVzPvGkRpoWaAkVKDhwfWZA=
X-Google-Smtp-Source: APXvYqy2gX8/EvePjsy3Z5Xr3iA9PdDDQx4HYrn6HE8zRxrK8/pHaC2wFoZpJAomjv9Wbvv9qSnHHu2D3zK7TbId5Sw=
X-Received: by 2002:a5e:8a46:: with SMTP id o6mr15923626iom.36.1566263797445;
 Mon, 19 Aug 2019 18:16:37 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com> <20190819211200.GA24956@tower.dhcp.thefacebook.com>
In-Reply-To: <20190819211200.GA24956@tower.dhcp.thefacebook.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 20 Aug 2019 09:16:01 +0800
Message-ID: <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Roman Gushchin <guro@fb.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	Randy Dunlap <rdunlap@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > In the current memory.min design, the system is going to do OOM instead
> > of reclaiming the reclaimable pages protected by memory.min if the
> > system is lack of free memory. While under this condition, the OOM
> > killer may kill the processes in the memcg protected by memory.min.
> > This behavior is very weird.
> > In order to make it more reasonable, I make some changes in the OOM
> > killer. In this patch, the OOM killer will do two-round scan. It will
> > skip the processes under memcg protection at the first scan, and if it
> > can't kill any processes it will rescan all the processes.
> >
> > Regarding the overhead this change may takes, I don't think it will be a
> > problem because this only happens under system  memory pressure and
> > the OOM killer can't find any proper victims which are not under memcg
> > protection.
>
> Hi Yafang!
>
> The idea makes sense at the first glance, but actually I'm worried
> about mixing per-memcg and per-process characteristics.
> Actually, it raises many questions:
> 1) if we do respect memory.min, why not memory.low too?

memroy.low is different with memory.min, as the OOM killer will not be
invoked when it is reached.
If memory.low should be considered as well, we can use
mem_cgroup_protected() here to repclace task_under_memcg_protection()
here.

> 2) if the task is 200Gb large, does 10Mb memory protection make any
> difference? if so, why would we respect it?

Same with above, only consider it when the proctecion is enabled.

> 3) if it works for global OOMs, why not memcg-level OOMs?

memcg OOM is when the memory limit is reached and it can't find
something to relcaim in the memcg and have to kill processes in this
memcg.
That is different with global OOM, because the global OOM can chose
processes outside the memcg but the memcg OOM can't.

> 4) if the task is prioritized to be killed by OOM (via oom_score_adj),
> why even small memory.protection prevents it completely?

Would you pls. show me some examples that when we will set both
memory.min(meaning the porcesses in this memcg is very important) and
higher oom_score_adj(meaning the porcesses in this memcg is not
improtant at all) ?
Note that the memory.min don't know which processes is important,
while it only knows is if this process in this memcg.

> 5) if there are two tasks similar in size and both protected,
> should we prefer one with the smaller protection?
> etc.

Same with the answer in 1).

>
> Actually, I think that it makes more sense to build a completely
> cgroup-aware OOM killer, which will select the OOM victim scanning
> the memcg tree, not individual tasks. And then it can easily respect
> memory.low/min in a reasonable way.


I haven't taken a close look at the memcg-aware OOM killer, but even
with cgroup-aware OOM killer I think it still can't answer your
question 4).

> But I failed to reach the upstream consensus on how it should work.
> You can search for "memcg-aware OOM killer" in the lkml archive,
> there was a ton of discussions and many many patchset versions.
>

I will take a close look at it.  Thanks for your reference.

>
> The code itself can be simplified a bit too, but I think it's
> not that important now.
>
> Thanks!


Thanks
Yafang

