Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09321C31680
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 18:15:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEB302085A
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 18:15:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IOHHR2OU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEB302085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48CFE8E0004; Mon, 21 Jan 2019 13:15:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43D0D8E0001; Mon, 21 Jan 2019 13:15:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32BF78E0004; Mon, 21 Jan 2019 13:15:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF7A58E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:15:30 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id k1so10651383ybm.8
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:15:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dN5/s/XUWtr4R+hciq572ZMFFMmCWF9muiwkQY2A1Ro=;
        b=bi3CiWIHs9m/ulPFdtJJ8PZ+HSCCKiAOYHLCoAqfZz3hn68UYSBJhwNq/4BJCOQEij
         OgIYqIGRKRX9uXR91VIeVhsuEonOzNbRromtArrDfvDcXa2Qg/DaEOJ7Jxw6+VYVsIC6
         FO9jBM+BEZOdt513SRf6ICYZly9M/FGYilbgNns8dUY/GmC85sFjihrIDTlce2kjXb4b
         OXXyaS5FzQss7QGziNpoxlCc7xw94LD3REEYnJ6BQFVJzYfR//6xXrKQW9htN2CGrwor
         AOSyDtwaGK3V9d4i/qt34rXgNaDfwGr8k2o0CKr1xuh2mZ4TAuRQDdd6Z1nSJZHYqD6C
         BdOw==
X-Gm-Message-State: AJcUukda55WjA7nEkmkqTZCDSrLP19QLRjtmTj+RdmnSDlYk88mBfC27
	1BsW/kMyzcNeyk545mn5+j1ENXaSKEo6dsWLGeVw/21cBMD3Qj4xAfMGCZfyYiG4Dmfp7vQqzth
	RvZyV50CzYgVY/oE256jQa7GmX/WsHIsiuiGKu6ZJymsNZhgOtriXGAMyKb/3/SNyFzcwyPgHkG
	7aUqNcp4/la6Z8dgbg+syFU/oy1K9Ag23bBwWy4h5Y/oWVA3tBUNx3+LFklZA5aFFqKboH2HZjE
	0yJs1TtMitLD7hQUA3iaxit5rDQ4HEKW1XmyocGhTRudUktQgUoKgcBg2aVDqcw2ooIJFk4pkkq
	XFjOgwBlN3F1yDlRjGLATsq1C2/zlJEVO9HNEYdkfUqpLqIl0tvJekUTJETShCucxHySI3UP1qq
	d
X-Received: by 2002:a81:3413:: with SMTP id b19mr29188880ywa.297.1548094530592;
        Mon, 21 Jan 2019 10:15:30 -0800 (PST)
X-Received: by 2002:a81:3413:: with SMTP id b19mr29188834ywa.297.1548094529874;
        Mon, 21 Jan 2019 10:15:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548094529; cv=none;
        d=google.com; s=arc-20160816;
        b=PiO+PFDVV0PFADog0dHO7aMZukgDot9yD+ikci6X+CNWjOhwPKvgB3kqOHwbat5Q93
         xIznAs590Ndsg9waX6BP8Iyq418GPbZ1LpopQ6LjtVzTFGtvshJx+pW84Ly9A1sRBWvw
         Wb9QfGsfTqA+ngdP8Epy/DHxj0LQkJOq+THMmzsE8NtjSxtuB4DEG/hJbkKWl2hHlDnx
         /vNH8BSUoFG9nSQwr4KS4FpVmAbW950fhW7aPUK/m9BflOH5d8xrM5gDmV6aUHuY6cU+
         QWcbretBsCsFvKLTluIrSIvcxFq1jaXb6x/CVkRjYa7RuGkkd56lSgbqkzrV4uDJQNwa
         XWmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dN5/s/XUWtr4R+hciq572ZMFFMmCWF9muiwkQY2A1Ro=;
        b=gLOflaCx42sQbHrPisR0xXqlTg/pcDQPLQ0dTHBGXEeWPonPo8EszXpEyc+rL+Zry3
         /nhgAMdRQ+F/h8Z1h9mqgC/wcMcYJeH/eXCBWfrTNz83aNijPhwZxfimoGgljkKXCrk5
         3j9Tk6HxBMSrvNx18d8Jnqbl/MFIPhQnfdsPYH8al0R1vx0EnSWsBU9x0ra5MckJvy14
         zZk86VJT2Kkv8zxz/SDqTErelP1GnzzcZ8G1y0h6lbteIyAflpUOSoFebYTC04tKw6aj
         gI8QXMTZ3K5b2fAU77OaB4csmX19+ufesIxnREBfTHpTzWxADwCxox+QgR4n77bUmNLv
         P7Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IOHHR2OU;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor2336267ywm.164.2019.01.21.10.15.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:15:29 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IOHHR2OU;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dN5/s/XUWtr4R+hciq572ZMFFMmCWF9muiwkQY2A1Ro=;
        b=IOHHR2OUoewqIH50EfJYP38TnMfwXAc6OQbrMN10yRCubGK/CrShrmBLRquouKYDzH
         HB+oW5fQ4dHDEG91tlYJPdg3+AvI50J/zFqSr83RYPBgCg6tgfAvzopk+QezvWbu+M/Y
         OvsoHv5C/zTsRoUywlvpVm8N68TOtTCmC+mb/dUOG9JXvvLgLeKIDvjo5U8BJhaxfdwH
         zPdsGqdXPZPo3F/Cv/d4SeroUSE0gY39PbokFA34P8/cVzbsfWk1HrHyV5jJkmDso/sV
         FnZhdkF8IWFngwH8KhWwF+jK8h4QaR3J3sNWe9FlmVJIKWhHqL/6KvaHIUgDTzK72Pve
         UgAw==
X-Google-Smtp-Source: ALg8bN7SqatxKiefMH/BPS7xmsTYaT1b4vk3z48wm/xEAutSusia6vLNJKjGcO6boH3FpVwT4GnoKNuxWY8VHrQZfo8=
X-Received: by 2002:a81:60c4:: with SMTP id u187mr29062429ywb.345.1548094529269;
 Mon, 21 Jan 2019 10:15:29 -0800 (PST)
MIME-Version: 1.0
References: <20190120215059.183552-1-shakeelb@google.com> <201901210123.x0L1NLFJ043029@www262.sakura.ne.jp>
In-Reply-To: <201901210123.x0L1NLFJ043029@www262.sakura.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 21 Jan 2019 10:15:18 -0800
Message-ID:
 <CALvZod7OxOiGgXfC1xjQ0z5GrvMQCVCZ_1=B+B7Ggo-z3+BqEg@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: remove 'prefer children over parent' heuristic
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121181518.rXUbeSrbu1tpulxYJjx73HVRqLlfFFNoMLrcGl46zb8@z>

On Sun, Jan 20, 2019 at 5:23 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Shakeel Butt wrote:
> > +     pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> > +             message, task_pid_nr(p), p->comm, oc->chosen_points);
>
> This patch is to make "or sacrifice child" false. And, the process reported
> by this line will become always same with the process reported by
>
>         pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>                 task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>                 K(get_mm_counter(victim->mm, MM_ANONPAGES)),
>                 K(get_mm_counter(victim->mm, MM_FILEPAGES)),
>                 K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
>
> . Then, better to merge these pr_err() lines?

Thanks, will remove the one in oom_kill_process.

