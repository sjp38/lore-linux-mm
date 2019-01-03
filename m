Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 011B2C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 16:18:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1D22208E3
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 16:18:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="P9PpFd3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1D22208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FE538E0084; Thu,  3 Jan 2019 11:18:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D41E8E0002; Thu,  3 Jan 2019 11:18:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EB728E0084; Thu,  3 Jan 2019 11:18:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0D58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 11:18:22 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id e68so20766396ybb.4
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 08:18:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nRuzp0vI0flryI3MP5+vDJIF6vIrlB4Ktla0xA64B1Y=;
        b=pnDIuJuCkfkUAEKS5jHvD8WVKGT1w7DKtQh7ADQaToBp2VgN2qfGQPil9O8Q3lonEp
         /qFU35Z8GIKwSYUiHBdeqFixQvKtJdecUnu0zeAJHez0I4PPv+sX3+JFn0L44bj/1heP
         XSgdRGpHhCSgGo35vJ792P8bs+7PE8aX57bj2OGzwHNhsmr177eK9tYw96JYWurZmr0H
         uZDaqTyzZxr63b/j1p6v1sZzjF8uAoLsD1Kown/RWD4+7r2KIwGsRb1qBE44cY3W332q
         I85IXOGjm2QZThsl8xZY+hm8Tk2FEuOtsAhxfFXfDfAYxiK6A30SggOc7r7uDvqbT0vU
         98GQ==
X-Gm-Message-State: AJcUukeGm0Zmw9KbpromRQv4/UIaI25ECq36QxcoXXHHQgsnjp6XNe0T
	r915PZJayFfRay8LFJ8l7tGgu3FW9gBkY1xfaOQJcnsA/05dGbqbdkIxhg2YNF9oz55phBQ3f7A
	lJp/WNGSozazevwuA1nzI/zGbOseDLhLa/yvYdTp+N7tuKdtkzOyUIkl1z1T3XOaBwVg6xUSs/Y
	eDzti1umPmlElUQNcCi1tLnneRtjY8BRI3ci1VUyaVcnNp8AFk4gkeQOrw7yVDjkLKThW0XPkmU
	ZPdy6j0dygSo4mpSgfmxsEsgHTqa82SA8C2Q+KFUOiSvhbJYPwZqkZuFSaSPmoIezRdkS+LDSSl
	U6qC4S2p1bKiMkcr4jVL1JFrGM0tlvsk1K+rQFNhksGM5v3NJ4wHBei/BoKrP2DbinZczsY3TOU
	k
X-Received: by 2002:a5b:892:: with SMTP id e18mr36959252ybq.380.1546532301723;
        Thu, 03 Jan 2019 08:18:21 -0800 (PST)
X-Received: by 2002:a5b:892:: with SMTP id e18mr36959211ybq.380.1546532301012;
        Thu, 03 Jan 2019 08:18:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546532300; cv=none;
        d=google.com; s=arc-20160816;
        b=YV/1nf7FobnO8xnXAXx1DmkioAnyF7AgyvLJVjs0Zv4tQ/rNfpTQWvl/RL30uoX6Oe
         DG7c2qDsveADQOyytgSxesysXhbYswulom+4Zhs7Z62ycQ2dEtnOpL7a+QnBAZzqND9L
         ossFQQmSbQ5gtdQSNRnOezqGWutop7yVjAtUe4+qS1uZrz5yzANW59HmCXAR+KWUjvHe
         RX45Xm2hjw0GbHR2itPCSA/tGww0/JXP/BYPTc2kAKh+unjFhaR1Du1dsufL0nWv/7tB
         GdtXXzoHASKszHhg1ad83ZEjBM5xKBndBlRY9mzE/xEGR8qVx6ZtYzZ5PhzhVYzhKb7k
         XG6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nRuzp0vI0flryI3MP5+vDJIF6vIrlB4Ktla0xA64B1Y=;
        b=zJKi01bKuxAj7dGnyyj1bwyG0afr31/ZkLuaQg4CAilkYqCzBFZw6CLAFZYJNwOUx8
         sd0JbNStbYZCLnDFFi9Lm3Tmw+oF2W4JSKdEGLyvcUr/VmKa7yXIGPl3nnNxverGR7YI
         4P53GfHIoCcpSFpvTvfIAwT7PBtUwP7/gbPbLE6FCWW4GK6CqIrLhUdvj5VePACI4D61
         nzRO6nS1P72QYj9aruacMihMx842X2dKQ7XSWZkue63nAmWURG2qzMOXhdiwR1ZxfNwV
         TZ1vQHojVsj3lwkmRMOQKdm1M/rrOmoFt3VpmkWOWDMm7ixP8lURWYkC4Z1cI89hN+WI
         hhTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=P9PpFd3n;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor9675709ybq.187.2019.01.03.08.18.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 08:18:20 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=P9PpFd3n;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nRuzp0vI0flryI3MP5+vDJIF6vIrlB4Ktla0xA64B1Y=;
        b=P9PpFd3n7HFykVrlxL8ZDNljuAJ/n4gopOyvWY6bWuAMNKTRC8Xro/HUuAj2m+8Q+w
         tvTGTCrHEGsoSaFRZnR4jBBwCl5W5K+Jcap4iSOC29bEZeTvAQeh6LpUcYZt9UWRUDm/
         V07rtj1AARtUg4eJR1vZueQaNHE4PmTrtxvpLUb+Dx8b+DyI4KocCEC9E6gNMqfUKw2P
         ynAQgrWxWdMUZcFyR2dN+CkU7mHx40FNdy8gVu5iDVUfsUETVMEdbQunpaRdXfKb0KFs
         FmMikP6SYycVjla6fgf5S4WLb0KQsEnOPCXZ737utsNhrdzo1HfuovNeWa7cawc386Kl
         mgqw==
X-Google-Smtp-Source: ALg8bN6zoDyrvoFDNcOIR1iqUPk80TIVnFl3r2XKj/GeBrT0vMCsvmgMujQF2FBzaT0VeIssxklpz2+N9+oihSzQ104=
X-Received: by 2002:a25:a269:: with SMTP id b96mr18971395ybi.148.1546532300334;
 Thu, 03 Jan 2019 08:18:20 -0800 (PST)
MIME-Version: 1.0
References: <20190103031431.247970-1-shakeelb@google.com> <313C6566-289D-4973-BB15-857EED858DA3@oracle.com>
In-Reply-To: <313C6566-289D-4973-BB15-857EED858DA3@oracle.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 3 Jan 2019 08:18:09 -0800
Message-ID:
 <CALvZod5YSKZvWq13ptbfignECxLVH5H_1YbdvoghrmicuDwuSA@mail.gmail.com>
Subject: Re: [PATCH v2] netfilter: account ebt_table_info to kmemcg
To: William Kucharski <william.kucharski@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Florian Westphal <fw@strlen.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, 
	Roopa Prabhu <roopa@cumulusnetworks.com>, 
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux-foundation.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103161809.-SQqazhqUCP3vo7ct_6xkkt-hE8S5TWXs8qd8Kbesm0@z>

On Thu, Jan 3, 2019 at 2:15 AM William Kucharski
<william.kucharski@oracle.com> wrote:
>
>
>
> > On Jan 2, 2019, at 8:14 PM, Shakeel Butt <shakeelb@google.com> wrote:
> >
> >       countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
> > -     newinfo = vmalloc(sizeof(*newinfo) + countersize);
> > +     newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
> > +                         PAGE_KERNEL);
> >       if (!newinfo)
> >               return -ENOMEM;
> >
> >       if (countersize)
> >               memset(newinfo->counters, 0, countersize);
> >
> > -     newinfo->entries = vmalloc(tmp.entries_size);
> > +     newinfo->entries = __vmalloc(tmp.entries_size, GFP_KERNEL_ACCOUNT,
> > +                                  PAGE_KERNEL);
> >       if (!newinfo->entries) {
> >               ret = -ENOMEM;
> >               goto free_newinfo;
> > --
>
> Just out of curiosity, what are the actual sizes of these areas in typical use
> given __vmalloc() will be allocating by the page?
>

We don't really use this in production, so, I don't have a good idea
of the size in the typical case. The size depends on the workload. The
motivation behind this patch was the system OOM triggered by a syzbot
running in a restricted memcg.

Shakeel

