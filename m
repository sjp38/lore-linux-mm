Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25D14C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:57:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3BCC205ED
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="bFe5M5Vi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3BCC205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A6F76B0005; Thu, 20 Jun 2019 11:57:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 758428E0002; Thu, 20 Jun 2019 11:57:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66D848E0001; Thu, 20 Jun 2019 11:57:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 070326B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:57:23 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 9so485042ljp.7
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:57:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jWGyLei7iIX0YquCcpJVdvUVmyD9HHcydfLdWLV6VdQ=;
        b=QZjAkoQ29Es/2zj2HUjX/68sLJ2Ardcj1OFk4MO/VdQeXhIWPl7J6CCZFwZanaFuSd
         yky8iwd3wyMJwEqeu2oddLPzSamOwfyrYEytnq2h9HZzooHv+8KUmNfBu2SKdLIrkEFk
         wQDu4fa2MinmrNPe+l/cCuRGxkHTlEcKV8A6xcoy038n4fKx9KbQxIlc0YnKbcVPk2QI
         JhKNifmDQKH/4GTaYqstRVmvVNUMhwnEqfX5DqNvjANbnPszHPyHUqy19gl9xRPfszN+
         Glze2qryGUn1EqW+hkviuOUyPOs3R7gGX8CUFS9a6LXqHTpBHCxWal4JuOWaaL1synkS
         d9uQ==
X-Gm-Message-State: APjAAAUz0DI8IIlaq6vCTjqLP5dLvjGJgbWck3UvRVzBxDh/z/v91XkZ
	Hf5FlaXBXeV1eozEe5DbdbMSasLGquIWLFc+n5ZzsgXWPLcuxGZ4+eOnZYlJpiY0PWC6DfextIK
	LJjtEu0EiWJAlzQKQVFwIoEDObGFr8h1XtLNpQK2boHTQo7Qax2xMI2M1xB5tD/M2wg==
X-Received: by 2002:ac2:546a:: with SMTP id e10mr18203290lfn.75.1561046242224;
        Thu, 20 Jun 2019 08:57:22 -0700 (PDT)
X-Received: by 2002:ac2:546a:: with SMTP id e10mr18203261lfn.75.1561046241348;
        Thu, 20 Jun 2019 08:57:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561046241; cv=none;
        d=google.com; s=arc-20160816;
        b=mJJmznm6j7Yvv6xUPbyzF9sRDGWvD3OcnzHxRbegRUpZo6jWyI7q0W/znOQlvmXFkm
         d58rnmetmAi2VhdpvJTXCdWyJaTmYfCeDSbnMspJ0u/f0y6UVbK/Ag8zgJh2I7BZkbkh
         keim21EE3JUwLkmHOje0Snu5tsx/Tltn/GcB0gjYHNNrZAyi29JrzUFn9BZaNSr9jdPf
         3Zb5ZHlJi3k5UAmUZnB9Fd1b15Immw8TmI833IaJLO8XkXOOESgPo55o3uBHxPX3fywK
         VsLCHqT7YEIf9gcJ/WbkCzWvKiTSVr4EvFrEsbAO7GliTjVtMsmEr+xJFFYPGZn/VKDR
         Za9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jWGyLei7iIX0YquCcpJVdvUVmyD9HHcydfLdWLV6VdQ=;
        b=jmgSvx6DzPZiTG2vAzduJBHUJxAUt2OM+6iz6i972xYWTgWwq1vDgrouX/Caq1qpk5
         x535ljw4xxM/ib3Yl8QGiGhc7VLpfnjGhVkZG4PJzq/uZcIv9AIMePIcOBF+ymYqfN5p
         KK47DaRk3y5BBaZZgLQdd/oGsh+j0XgT5hyYj5er4xFEZkogdUwIUK7zRAJW97anfQuX
         uzjkrNSpxCmdluVz9SfiXvvQ4vHgQooKgSGcmvNJF2BmBiuFbX7QmHTT/LSpv8arzfdP
         PlYavpDTqPuLrooms2c34ymkLfhTC23hbhQ7gx1vriVt6jZJlU62eBKnYqwMTgxDJ8Vx
         +aPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=bFe5M5Vi;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m7sor11253008ljg.14.2019.06.20.08.57.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 08:57:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=bFe5M5Vi;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jWGyLei7iIX0YquCcpJVdvUVmyD9HHcydfLdWLV6VdQ=;
        b=bFe5M5Viz6mhTHKLXiMPTsQHKWSneXU/P32CqJMYYaptrO+yxI3A5ZHrwgrV2u0KS5
         rMgI+Roe2+x3nxcZJ1pksI2BGPwWFMRIupONO1kQiB3020Q2Rgino0w1y37GLCitolpZ
         audrqCWFZ8YkyqtOjHihYhu0nEmriemTSSrqQ=
X-Google-Smtp-Source: APXvYqwrlNR3lH/4m9IeD5Bkl0pzlV3Ska/rPfDDBMmGCP6oxktUzG4DNWPlJ52+fxSnzyurONehOvGDKpiTNUq3KkQ=
X-Received: by 2002:a2e:3602:: with SMTP id d2mr7778406lja.112.1561046240877;
 Thu, 20 Jun 2019 08:57:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190603053655.127730-1-minchan@kernel.org> <20190603053655.127730-2-minchan@kernel.org>
 <20190604203841.GC228607@google.com> <20190610100904.GC55602@google.com>
 <20190612172104.GA125771@google.com> <20190613044824.GF55602@google.com>
 <20190619171340.GA83620@google.com> <20190620050132.GC105727@google.com>
In-Reply-To: <20190620050132.GC105727@google.com>
From: Joel Fernandes <joel@joelfernandes.org>
Date: Thu, 20 Jun 2019 11:57:09 -0400
Message-ID: <CAEXW_YSY2GgW_Fp6VN2Qrf0Gr8c71DUgoTzZoq-V2=jFgDEDvQ@mail.gmail.com>
Subject: Re: [PATCH v1 1/4] mm: introduce MADV_COLD
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Suren Baghdasaryan <surenb@google.com>, Daniel Colascione <dancol@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>, Oleg Nesterov <oleg@redhat.com>, 
	Christian Brauner <christian@brauner.io>, oleksandr@redhat.com, hdanton@sina.com, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 1:01 AM Minchan Kim <minchan@kernel.org> wrote:
[snip]
> > > >
> > > > I think to fix this, what you should do is clear the PG_Idle flag if the
> > > > young/accessed PTE bits are set. If PG_Idle is already cleared, then you
> > > > don't need to do anything.
> > >
> > > I'm not sure. What does it make MADV_COLD special?
> > > How about MADV_FREE|MADV_DONTNEED?
> > > Why don't they clear PG_Idle if pte was young at tearing down pte?
> >
> > Good point, so it sounds like those (MADV_FREE|MADV_DONTNEED) also need to be fixed then?
>
> Not sure. If you want it, maybe you need to fix every pte clearing and pte_mkold
> part, which is more general to cover every sites like munmap, get_user_pages and
> so on. Anyway, I don't think it's related to this patchset.

Ok, I can look into this issue on my own when I get time. I'll add it
to my list. No problems with your patch otherwise from my side.

 -Joel

