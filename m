Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9571BC3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:29:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BCFA22DA7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:29:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gVYZIY8B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BCFA22DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E156D6B0007; Mon, 19 Aug 2019 21:29:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC7E26B0008; Mon, 19 Aug 2019 21:29:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D04CF6B000A; Mon, 19 Aug 2019 21:29:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id B0EE76B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:29:51 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 207DA181AC9B4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:29:51 +0000 (UTC)
X-FDA: 75841074582.27.print18_55f94ef948c3a
X-HE-Tag: print18_55f94ef948c3a
X-Filterd-Recvd-Size: 6224
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:29:50 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id o9so8656889iom.3
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:29:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KKjD5A8NaZUrH/M43uDXv8CAljNHrPrsN4OaxgcIFWU=;
        b=gVYZIY8BzCrk1VyB29fczZF2tKYtOEIigjrlogTwEIWHsU6+681mGRuSKV1Yaa1DNx
         YhD+oeBQZiyRrYCmRexgUUhbubEWfdOpvKgJJTU1Si+vT/BfbUOMZZ1+sM0D5wVH0Pvf
         TRQVXvTaXNLees07ZAko50w9Qd+1sQCFYvXI5hIcWyfDLuYYlrOq0JwiUCgLfalasdcz
         H9jCvAyI2ZjVEoZYsi4yXrHqUkKwX6TxQQ06ulagsxGTDdljwqBD170Rbf2dR2Pr8jr4
         pH4p6MM/NdLPN3alOV3IGTvm4PIl9GE0G2VU083yyM5LNAyJW/UBSLBgxjyoZZdLzo9b
         wKYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=KKjD5A8NaZUrH/M43uDXv8CAljNHrPrsN4OaxgcIFWU=;
        b=eeeWlLKCPvnAW+TL/z4suSG8vYkOZb4RFefM7yV8ovtKyfkfdfGEujrAxW+LYpBVtD
         v2/QGfRA4gcTuKOpcId3SKSXqXm5UNmBwfc+bFMiWu0mLgtsOMvVNqhpluN91c4Wx/v0
         n+Km3u9UZl9HFAdooePBlLoeuDlfYZUSVKhOEdkRVm03Wb/uab4Ar/+yZfbwVbFb0qV9
         QEmJD8vs8mx3J6Z7S3zZthctESVb6HV1HdaRhiHX2MC1sSdia+6lbCpmSXkfNJ1+78d/
         pUAgOcaMizb+NOdn/qSJ7apwINXuIQMcfwfJG/E0zsGGqRR9ji9WUhmAROKglTOkH213
         F9pg==
X-Gm-Message-State: APjAAAVRdK32yJfsUh+/rzji8kL4vbw/IFCXIME3sMXMOmBsem3kkOr3
	P2pqKBrdDaq6wo8COtqRukEZq8wTzliZ45B0eR0=
X-Google-Smtp-Source: APXvYqwsPm5MLF4aYGeG/QAtbB9h+kk5pi4C2nkEC0lE+bqaQGppmxMlXeVXIRPxp9/vOiGE3ZAhisVxV57qTI1WnWM=
X-Received: by 2002:a6b:e511:: with SMTP id y17mr547859ioc.228.1566264590034;
 Mon, 19 Aug 2019 18:29:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190817004726.2530670-1-guro@fb.com> <CALOAHbBsMNLN6jZn83zx6EWM_092s87zvDQ7p-MZpY+HStk-1Q@mail.gmail.com>
 <20190817191419.GA11125@castle> <CALOAHbA-Z-1QDSgQ6H6QhPaPwAGyqfpd3Gbq-KLnoO=ZZxWnrw@mail.gmail.com>
 <20190819212034.GB24956@tower.dhcp.thefacebook.com>
In-Reply-To: <20190819212034.GB24956@tower.dhcp.thefacebook.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 20 Aug 2019 09:29:14 +0800
Message-ID: <CALOAHbCwWHirJjmByeAVZdDoHpCMabq20tzMdhr_25Ddic9TYw@mail.gmail.com>
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM counters
 in sync with the hierarchical ones"
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, 
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 5:20 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Sun, Aug 18, 2019 at 08:30:15AM +0800, Yafang Shao wrote:
> > On Sun, Aug 18, 2019 at 3:14 AM Roman Gushchin <guro@fb.com> wrote:
> > >
> > > On Sat, Aug 17, 2019 at 11:33:57AM +0800, Yafang Shao wrote:
> > > > On Sat, Aug 17, 2019 at 8:47 AM Roman Gushchin <guro@fb.com> wrote:
> > > > >
> > > > > Commit 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync
> > > > > with the hierarchical ones") effectively decreased the precision of
> > > > > per-memcg vmstats_local and per-memcg-per-node lruvec percpu counters.
> > > > >
> > > > > That's good for displaying in memory.stat, but brings a serious regression
> > > > > into the reclaim process.
> > > > >
> > > > > One issue I've discovered and debugged is the following:
> > > > > lruvec_lru_size() can return 0 instead of the actual number of pages
> > > > > in the lru list, preventing the kernel to reclaim last remaining
> > > > > pages. Result is yet another dying memory cgroups flooding.
> > > > > The opposite is also happening: scanning an empty lru list
> > > > > is the waste of cpu time.
> > > > >
> > > > > Also, inactive_list_is_low() can return incorrect values, preventing
> > > > > the active lru from being scanned and freed. It can fail both because
> > > > > the size of active and inactive lists are inaccurate, and because
> > > > > the number of workingset refaults isn't precise. In other words,
> > > > > the result is pretty random.
> > > > >
> > > > > I'm not sure, if using the approximate number of slab pages in
> > > > > count_shadow_number() is acceptable, but issues described above
> > > > > are enough to partially revert the patch.
> > > > >
> > > > > Let's keep per-memcg vmstat_local batched (they are only used for
> > > > > displaying stats to the userspace), but keep lruvec stats precise.
> > > > > This change fixes the dead memcg flooding on my setup.
> > > > >
> > > >
> > > > That will make some misunderstanding if the local counters are not in
> > > > sync with the hierarchical ones
> > > > (someone may doubt whether there're something leaked.).
> > >
> > > Sure, but the actual leakage is a much more serious issue.
> > >
> > > > If we have to do it like this, I think we should better document this behavior.
> > >
> > > Lru size calculations can be done using per-zone counters, which is
> > > actually cheaper, because the number of zones is usually smaller than
> > > the number of cpus. I'll send a corresponding patch on Monday.
> > >
> >
> > Looks like a good idea.
> >
> > > Maybe other use cases can also be converted?
> >
> > We'd better keep the behavior the same across counters. I think you
> > can have a try.
>
> As I said, consistency of counters is important, but not nearly as important
> as the real behavior of the system. Especially because we talk about
> per-node memcg statistics, which I believe is mostly used for debugging.
>
> So for now I think the right thing to do is to revert the change to fix
> the memory reclaim process. And then we can discuss how to get counters
> right.
>

Sure.

Thanks
Yafang

