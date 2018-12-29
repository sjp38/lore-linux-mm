Return-Path: <SRS0=mZRB=PG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A214C43387
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 19:39:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3634920873
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 19:39:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IeK8dGvy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3634920873
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAF838E0063; Sat, 29 Dec 2018 14:39:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5E2F8E005B; Sat, 29 Dec 2018 14:39:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B74C68E0063; Sat, 29 Dec 2018 14:39:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF3B8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 14:39:18 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id r191so16985584ybr.12
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 11:39:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sBBN2mphyXf7II5d9cbYV+3gNH1blN+Ub//bXMWso6o=;
        b=KeAeCwDHsjd1ssP0fdLZBtmR07R68gf88wgasASnJqfCEG05jvCew9VayRfkDU0SQr
         SQMGjUJppA817z2a1UpANDVdBBaH0O3SLl4i0L13DnZXq5brpxjmLM2hRbO2G7u+UHIy
         NPPgVoqhdyYZpZ7yP9Qh1efl/nb8VlpZXHvOGN3Dow0hbzBkhqbOdSR0ydVfvTe8chwr
         cG2w9QOfYPNGAR6pxpyuglYQjwSFSOJMtmlLmRrrZRPKa7wC8P3tVOjBZXkpf5verBUd
         kDuZiwsCKL74JbtgyMPBScyaT4gR7VN6WJML0n66jf11HYFqVXLf0tm9rnqCdmQ9XoiR
         0Ydw==
X-Gm-Message-State: AA+aEWYdHhjH4dIBc4xunvMqj5fgg9E1a1M4XX+sL8+xUkhZ36wbw0GR
	oTpRPtaZ9SHFYbsdqu4dRUXEucpjR8nkQB6vc4T14FDbCQD75mQu705mcCEgBQV6utvkqUNO5sM
	hb6uvtcLPp0qwtNkqWgYZcXGEFr/FaFHAWLEFOokYbHPZllyL6dFtVEY+P2inBceWHXGiwa8fj+
	Q+w0OGoZ899jv0rdo2OCDgsrOK/NOtXwQLHQDMp+79bVeb+x9/vDiD2jPHlki40T0L8NiKvX4Lr
	2O7zm0sE7EJnMzspGLuFzG23r3yo6voeXB619aVBskRhgCnhMSlAhlTbJPxk8H479W89wdphxzK
	7ENjIC/HUW471VVsATUKkDg4TkPjs1fNWGYPwSqf93IQwp14waVwmqVi4hDmSucE1LHmUIwI5vL
	V
X-Received: by 2002:a81:5f88:: with SMTP id t130mr32269784ywb.494.1546112358309;
        Sat, 29 Dec 2018 11:39:18 -0800 (PST)
X-Received: by 2002:a81:5f88:: with SMTP id t130mr32269768ywb.494.1546112357856;
        Sat, 29 Dec 2018 11:39:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546112357; cv=none;
        d=google.com; s=arc-20160816;
        b=av0gHlX/Q4v0uwVHkO43Fs8pIerFR0XAiCIrfdUNi+BexbQ9sLXc671qkO1adZS+R2
         JwG7u1QWFrWCX9JqAT3PUA7zWq2EWdSF6LpsoArBduxCyE27bR6WwPybKzlmGtaxPRtR
         G3kvYHUA06zcDnyUq/D8j4G2uqKNUUV6aLUo++PSVJJEOtEFUA341PG79Ox6XNwf+9FY
         Mxia/k3UcNwTXugZysAjj8PFyLsy2YLJ8UWT/KgrqtXz4vvBB4IWSfq7ypKvHtNIysCD
         yoQZUmchY8f0I1n+ggkDNw7W2+4WkZlSuAJRQwtaZ17gF43TbImUOXmlOYZI0jRaoVuD
         Nkkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sBBN2mphyXf7II5d9cbYV+3gNH1blN+Ub//bXMWso6o=;
        b=AxWcawdzcDxaWpH+g/rYKiTWq7pEH5z0dSlHYfw9EOvXpqo0G88oaRCJJNxy/9P6uF
         1qVYV42fKDXQpyi2zZ/KMmAYIwDk1vXKuHngbs085Zuc7JXq2MCoufslwsoyGzJcC6SE
         ZY/7RwtUB55VernYE9gdy9FfdWvZfRcTTZ1nz8E7J6EHUfGy889c6WrVB1Sa+AjD/epJ
         DgNCbW+rZcRHO3BUVP5IPa/9zHsA5VRGT8tmxjYORhkBUrk5alcmzJWWd7/HlDo7gyFB
         zCxq0UGI6COIpSnBFnb2sHWbb53GQNz66cHf7kXtKwSdJZt/I0hZ3cbDo54+2Vx9IUSK
         G4Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IeK8dGvy;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor6088168ywa.0.2018.12.29.11.39.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 11:39:17 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IeK8dGvy;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sBBN2mphyXf7II5d9cbYV+3gNH1blN+Ub//bXMWso6o=;
        b=IeK8dGvyQFN1k5SZbplWXk3V0SIzw9j2rmL9koMjC7iv+qPVeovSwAMzOdqgUS3Kcl
         //2YwH0lVSrhCJlRATLtfOrcdYoOQHC3jCT3jFt2UZJaa/3FlOQ95FC5UUiwBan0RacU
         LDnWYlyPEXx2bKploZ3oYHeihW3luV6f0+VKJlrn5CUw8gRkUGdGIrzEgrOYTU7byRpv
         Tu7gL96vgYK3WtV5ssyHpNNKjTtTtWOBOqf10+WcS0fii4X3P4JFJG2+QhEphYoY5Tn2
         6x4aeFCKX0ZWcD5CaemqpzJCKLptsuukhgC65wMqmM9tsYdi1xliAQyTvqCzmiG9rqoc
         CRLQ==
X-Google-Smtp-Source: AFSGD/VNzN0sznBQKNWyIE9lVvYn+Yku7qopyFK6Kzv9Ir+NtzY0f/EA1+sPzg/kT2UVezzNhV3E1sCC9t3lOzFPuBw=
X-Received: by 2002:a81:ee07:: with SMTP id l7mr32007083ywm.489.1546112357402;
 Sat, 29 Dec 2018 11:39:17 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <7c0fa75f-df2f-668e-ebc2-3d3e9831030f@virtuozzo.com>
In-Reply-To: <7c0fa75f-df2f-668e-ebc2-3d3e9831030f@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 29 Dec 2018 11:39:06 -0800
Message-ID:
 <CALvZod5FxsHk9UFvDewoVftWU0AB=1JJCEgd6B-5np1CrXwRvA@mail.gmail.com>
Subject: Re: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, 
	Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, 
	Roopa Prabhu <roopa@cumulusnetworks.com>, 
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, 
	syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181229193906.yO_MRsI9i_ma1CdkIa0QcrbhPeuiL0o79tWugFz6Y4U@z>

Hi Kirill,

On Sat, Dec 29, 2018 at 1:52 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> Hi, Michal!
>
> On 29.12.2018 10:33, Michal Hocko wrote:
> > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> >> The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> >> memory is already accounted to kmemcg. Do the same for ebtables. The
> >> syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> >> whole system from a restricted memcg, a potential DoS.
> >
> > What is the lifetime of these objects? Are they bound to any process?
>
> These are list of ebtables rules, which may be displayed with $ebtables-save command.
> In case of we do not account them, a low priority container may eat all the memory
> and OOM killer in berserk mode will kill all the processes on machine. They are not bound
> to any process, but they are bound to network namespace.
>
> OOM killer does not analyze such the memory cgroup-related allocations, since it
> is task-aware only. Maybe we should do it namespace-aware too...

This is a good idea. I am already brainstorming on a somewhat similar
idea to make shmem/tmpfs files oom-killable. I will share once I have
something more concrete and will think on namespace angle too.

thanks,
Shakeel

