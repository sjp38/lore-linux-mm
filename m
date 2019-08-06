Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B4DAC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 03:28:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2578320C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 03:28:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kPmJavQl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2578320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAE5E6B0003; Mon,  5 Aug 2019 23:28:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5E876B0005; Mon,  5 Aug 2019 23:28:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B75976B0006; Mon,  5 Aug 2019 23:28:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93BB96B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 23:28:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y19so77754249qtm.0
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 20:28:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aoJs4+GZcrMW12maFhHxBWCjreCnZG8IIroKJ5Dk56w=;
        b=PIEpklZ0w2QgXaRuo25uw79qAg5BT9dsgai1ZA5xfgL6N6W9CLWX/GQjDc/WuJfTmo
         jLir4JCtguqrV9I/vgkA1S5j5iaCXIu7/51kTNEIcN6+svU313h6kmplkMmg+qU72cWf
         l3bE+dKJWnEh+74YHgB0yrYRnHL20TLzG54pJbU0QmyaLCE9UZ4Hwj9VTiawGDKpsXsz
         W9QLxvcDEqHrI9cahGVAeUEAoYEROA7Mx17luklzmzql/7jwoTU+RzQgLwVD76zyIV87
         058DkvrzX162CxcBm1yHoRFP9LaqsX1yqbWMU15/9ut2PHgJOa61SMjc9wSlXeLhmd6g
         ecZg==
X-Gm-Message-State: APjAAAWtF7YAzoYt87Jt7zY3lrYfAiYa1E43CLISwH12PIBTxk6Y43OQ
	nUYUKhZKDKPj7Vj6gJ3CbQiQQbEajhKHYtfWWpaNHGUR94PxdMhx+UAdxsxMOzs+HUkskt49ebS
	GlbD0Rzg7nAw6EwvsQAz+8dA3pdRZ+uyu4qo/HSQi6rODDZhx6epx83GzpQ4xgy7xvw==
X-Received: by 2002:ac8:7404:: with SMTP id p4mr1175922qtq.181.1565062133313;
        Mon, 05 Aug 2019 20:28:53 -0700 (PDT)
X-Received: by 2002:ac8:7404:: with SMTP id p4mr1175897qtq.181.1565062132649;
        Mon, 05 Aug 2019 20:28:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565062132; cv=none;
        d=google.com; s=arc-20160816;
        b=w/7xwW5xAdOCE5zQPW067Pucjv1rwSTxg+Zq/j7q3lcjv8ypur4MRZ6B0yEj97MO0e
         IVqwYDw20USdH9egscFDGsxajLrco4r4mSkatDFkBelZuMuqY6c7/Hjg0kchURsRMjn2
         2WlxsFL72r0clbYspZJeYCuvUwzGgJ8mrc7k3ndsok/nPUnLwQ1YMEYuxbv8PwWyHffv
         dPtGMHYCfmGFuV39n60WuJhqAaP/asP+WGE0J+8++k7Rm8MEcIPjr28QE2G3rNDWiCk/
         9jxziwjenlkcM+be+a40ghpskuAY8hXQCW32Gm/QjpKkRi9AOW0Estxp+NhXD2IgSquK
         fY1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aoJs4+GZcrMW12maFhHxBWCjreCnZG8IIroKJ5Dk56w=;
        b=Hf80FyBS8eOj5sfI9e1xAVhwXh6Sta02JmVtzQs1nKepermSifiYQG9gu0yt0SKVqO
         3np3iX5+2/g0rOc/2ttng/yFPXtsMXB+Oi/c//XvGcBSQ+ZSBu47e2raAfoJVoEZBaEc
         HZ5gsLgWnQOcs5qWtEZRez9HzW0lAXCRTz7QKMxVBRRfCh0jTOA3VBauCM5hTFqkBard
         XLBMRg5kLN8kAsEseqEucARXps0D89xAVD4wJrR8wXC/Et9IZPvRiW1BA2Bd7E5jvlzW
         Vg8oHCcCAwPEqZiu5FRj2/EHuO5JjeI8hmom9hdmWQIKgdC7bnSSexn7rD/vluwp9MGw
         wSpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kPmJavQl;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e47sor110873488qtk.72.2019.08.05.20.28.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 20:28:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kPmJavQl;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aoJs4+GZcrMW12maFhHxBWCjreCnZG8IIroKJ5Dk56w=;
        b=kPmJavQlKC0qoOuF78dkRk9X6JVlHFkwGK1peHZHj0UFVxLbLlTm/X+vuwLi6rDTmY
         aXayCcF6YYeKFgRSI6W+734GagJiaJfX8BHoIixitFMdY/4AsEYsSaLqxSWluMm4xaSE
         zA7OGuMlaprEKB+sr57Wibi7sFwTkSY3z2Me5Qe32x+F596HUdYRuJFkul4bFSQprW1q
         JrldsZuhof5957Q/xkny1ZgQ2FPbIB6s4K1Vc5E/R9BsiqIKmSkhL5Dd60a7+AyG0Mih
         9XtZ7rSBPguMqHF6magt/107WW1GNFKFxW1lzNzuAAIYzmWN5NHZb3YqFy8xH567gitR
         vi3A==
X-Google-Smtp-Source: APXvYqz6dPCfj+pirXMMo99Ejr8ClrpVzZXvEm5OpbqIaQEx0AF8UPM5lFBqF88MBMF0yiaRMwtPQsCKPr2MU1U78kg=
X-Received: by 2002:ac8:f3b:: with SMTP id e56mr1164468qtk.123.1565062132340;
 Mon, 05 Aug 2019 20:28:52 -0700 (PDT)
MIME-Version: 1.0
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz> <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz> <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
 <20190729184850.GH9330@dhcp22.suse.cz> <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
 <20190802093507.GF6461@dhcp22.suse.cz> <CAHbLzkrjh7KEvdfXackaVy8oW5CU=UaBucERffxcUorgq1vdoA@mail.gmail.com>
 <20190805143239.GS7597@dhcp22.suse.cz>
In-Reply-To: <20190805143239.GS7597@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 5 Aug 2019 20:28:40 -0700
Message-ID: <CAHbLzkpD+kawkR42mWpxvZHvSZNhYEsibiMYzx+3q0rTBS6L9g@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 5, 2019 at 7:32 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 02-08-19 11:56:28, Yang Shi wrote:
> > On Fri, Aug 2, 2019 at 2:35 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 01-08-19 14:00:51, Yang Shi wrote:
> > > > On Mon, Jul 29, 2019 at 11:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Mon 29-07-19 10:28:43, Yang Shi wrote:
> > > > > [...]
> > > > > > I don't worry too much about scale since the scale issue is not unique
> > > > > > to background reclaim, direct reclaim may run into the same problem.
> > > > >
> > > > > Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
> > > > > You can have thousands of memcgs and I do not think we really do want
> > > > > to create one kswapd for each. Once we have a kswapd thread pool then we
> > > > > get into a tricky land where a determinism/fairness would be non trivial
> > > > > to achieve. Direct reclaim, on the other hand is bound by the workload
> > > > > itself.
> > > >
> > > > Yes, I agree thread pool would introduce more latency than dedicated
> > > > kswapd thread. But, it looks not that bad in our test. When memory
> > > > allocation is fast, even though dedicated kswapd thread can't catch
> > > > up. So, such background reclaim is best effort, not guaranteed.
> > > >
> > > > I don't quite get what you mean about fairness. Do you mean they may
> > > > spend excessive cpu time then cause other processes starvation? I
> > > > think this could be mitigated by properly organizing and setting
> > > > groups. But, I agree this is tricky.
> > >
> > > No, I meant that the cost of reclaiming a unit of charges (e.g.
> > > SWAP_CLUSTER_MAX) is not constant and depends on the state of the memory
> > > on LRUs. Therefore any thread pool mechanism would lead to unfair
> > > reclaim and non-deterministic behavior.
> >
> > Yes, the cost depends on the state of pages, but I still don't quite
> > understand what does "unfair" refer to in this context. Do you mean
> > some cgroups may reclaim much more than others?
>
> > Or the work may take too long so it can't not serve other cgroups in time?
>
> exactly.

Actually, I'm not very concerned by this. In our design each memcg has
its dedicated work (memcg->wmark_work), so the reclaim work for
different memcgs could be run in parallel since they are *different*
work in fact although they run the same function. And, We could queue
them to a dedicated unbound workqueue which may have maximum 512 or
scale with nr cpus active works. Although the system may have
thousands of online memcgs, I'm supposed it should be rare to have all
of them trigger reclaim at the same time.

> --
> Michal Hocko
> SUSE Labs

