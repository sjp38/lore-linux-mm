Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41867C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 09:35:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFDD1233A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 09:35:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qOmYeVVw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFDD1233A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91EFE6B02ED; Thu, 22 Aug 2019 05:35:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CE136B02EE; Thu, 22 Aug 2019 05:35:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E3E56B02EF; Thu, 22 Aug 2019 05:35:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0133.hostedemail.com [216.40.44.133])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA076B02ED
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 05:35:32 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E9D91181AC9B6
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:35:31 +0000 (UTC)
X-FDA: 75849556062.22.dime23_4d5cb7b495057
X-HE-Tag: dime23_4d5cb7b495057
X-Filterd-Recvd-Size: 4886
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:35:31 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id l7so10531306ioj.6
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 02:35:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JXL8Bgd1NTdiGNb2EOO7Ywv12WeIDCaYn/7GGlihWuU=;
        b=qOmYeVVw80eSlWG2jhEg/SH08VXxkSSVtgRNtcaky7swIHbXUQIGsBVABt7+ENq9qk
         KZA8lJJXfLQCCGzw8ZYSiJxziAYoaSQ7CsV4D5x02BThXqoixvhsyxxIOd8HmhVU14P2
         PQ8zmJ38HNMhqyNaQ4iLl3JZNIz4jlLLSyVeCzgMHiEqgYB9tF/vWkckjdo3W7V96Ucs
         D6NDFs/il9qM/Eaz0ay0dz6sBsQdtSxCN1TFIh5bCjBoYw4C3ItYWKzIT6tBEfcW/lyR
         FEBCyyGo6XJQ5PVAZ5kHy54a8gP79daLZ9xXa9+mEg0UILrChmxvMa7V8iLk6jN7iAeb
         kd8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JXL8Bgd1NTdiGNb2EOO7Ywv12WeIDCaYn/7GGlihWuU=;
        b=PH3avrFcIXrysAy2EG0bvFoZfiuEJNV5zSHBb/9cW3LWj0JolqPn07bVp2O6G9tLjr
         tAJoxoot8nt8JLNzVmKCory3QRwanXpBpCt/F9ih4FnwaFiLCjsWdWXdkssHobtvoll7
         ENP0oIuWznZ5TBgGWjCBi7Nyo6gqVo7FkfnyqB9rmWlf+ruSW2g8X3Jan2hZxDWOO6BZ
         /7ebz4bSBqhilSYJV1h56OUEdGQ7TsKbQPcsb3CaswNUB2HN7KN8tJJYnw0Ob255Bzkh
         KLzmbJhWxACJbVmfEBVGPstgm7J5alBx/spCbypeHEhmNr3xH+88LNkWTGRCDGgZj9BT
         RKeA==
X-Gm-Message-State: APjAAAWzsukyaMbXr3srcQouu/nAVBCUJdbx73pkwEbQJi/62ufvrbNj
	GGAbbCoqKTUJMNcBp4IaaSdVvq1BDp1cThqE2Bk=
X-Google-Smtp-Source: APXvYqxCmCz4floBFlltzUhioGjOrqlPLbtYS8qUs0SOkCsPsvBPQlcimA0irZd+XZffzLkfuu5pReVx8U4FrUf8a8k=
X-Received: by 2002:a5e:8a46:: with SMTP id o6mr777646iom.36.1566466530877;
 Thu, 22 Aug 2019 02:35:30 -0700 (PDT)
MIME-Version: 1.0
References: <1566464189-1631-1-git-send-email-laoar.shao@gmail.com> <20190822091902.GG12785@dhcp22.suse.cz>
In-Reply-To: <20190822091902.GG12785@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 22 Aug 2019 17:34:54 +0800
Message-ID: <CALOAHbAOH+Y+sN3ynAiBDm=JWrm4XpyUm8s3r9G=Oz4b0iNvCA@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: introduce per memcg oom_score_adj
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.005403, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 5:19 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Thu 22-08-19 04:56:29, Yafang Shao wrote:
> > - Why we need a per memcg oom_score_adj setting ?
> > This is easy to deploy and very convenient for container.
> > When we use container, we always treat memcg as a whole, if we have a per
> > memcg oom_score_adj setting we don't need to set it process by process.
>
> Why cannot an initial process in the cgroup set the oom_score_adj and
> other processes just inherit it from there? This sounds trivial to do
> with a startup script.
>

That is what we used to do before.
But it can't apply to the running containers.


> > It will make the user exhausted to set it to all processes in a memcg.
>
> Then let's have scripts to set it as they are less prone to exhaustion
> ;)

That is not easy to deploy it to the production environment.

> But seriously
>
> > In this patch, a file named memory.oom.score_adj is introduced.
> > The valid value of it is from -1000 to +1000, which is same with
> > process-level oom_score_adj.
> > When OOM is invoked, the effective oom_score_adj is as bellow,
> >     effective oom_score_adj = original oom_score_adj + memory.oom.score_adj
>
> This doesn't make any sense to me. Say that process has oom_score_adj
> -1000 (never kill) then group oom_score_adj will simply break the
> expectation and the task becomes killable for any value but -1000.
> Why is summing up those values even sensible?
>

Ah, good catch. This needs to be improved.

> > The valid effective value is also from -1000 to +1000.
> > This is something like a hook to re-calculate the oom_score_adj.
>
> Besides that. What is the hierarchical semantic? Say you have hierarchy
>         A (oom_score_adj = 1000)
>          \
>           B (oom_score_adj = 500)
>            \
>             C (oom_score_adj = -1000)
>
> put the above summing up aside for now and just focus on the memcg
> adjusting?

I think that there's no conflict between children's oom_score_adj,
that is different with memory.max.
So it is not neccessary to consider the parent's oom_sore_adj.

Thanks

Yafang

