Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DDB2C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CE5920850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:48:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jyT0I88f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CE5920850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD71D6B0266; Fri, 12 Apr 2019 05:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A60606B026A; Fri, 12 Apr 2019 05:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9507D6B026B; Fri, 12 Apr 2019 05:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73C4C6B0266
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:48:44 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id j8so8134681ita.5
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=idRrgLQbh43uv5SWzcGBZ8Bw6NnS0EFw56f1NhH2bmU=;
        b=FVOUcaD3TBf0tYR6U0v8aWtJd8oa5V6xGIbjcJT65sPoq7U0a71Gi73EfA5GffrQDw
         mdDwzLd8mqThmQ789fKUS1ojrQCQnQFUKX+970jkoEfvoCXCQgKTsX1LYS+K5gS9Fo1X
         6anl6+r8AMsHk4OGPEBpny3UL2Z9JlEOTedvhx7uKlAXBx6C4PtxLpERkWaGue/H4zRC
         mH2WRapo98DiFn0ME8mMKQSpm6DYdxIFMqcttj5Nhbb+gbJTbZzae+V3YUFdseUlLgfL
         jv7e3Qo0kK+0j8yzYDTbLE+M1UxQTelFLucNdDSB/62Hjx0wTgOBM5pKtcpKX9G9cDUd
         nglg==
X-Gm-Message-State: APjAAAV/ZXi55sZylt9IYmQd5OHAZTW0/cNHnNhmkXeuINmwSlkUJGtC
	Dx7Ad4pCt0QmJtBqjj8JSGLWu6vgOvkmv8ETKdVJf5aa875pT4zoXYpKXnt/b7Cc2ZYV15IwpIZ
	pMTEiwe5Dcmg6l3zG51PEyq6amAqozN+XNCMWOq9mQ71tUwMMt8EqoFMjVDSmDfG7yQ==
X-Received: by 2002:a6b:c3c3:: with SMTP id t186mr37083851iof.19.1555062524223;
        Fri, 12 Apr 2019 02:48:44 -0700 (PDT)
X-Received: by 2002:a6b:c3c3:: with SMTP id t186mr37083828iof.19.1555062523552;
        Fri, 12 Apr 2019 02:48:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555062523; cv=none;
        d=google.com; s=arc-20160816;
        b=xUh8Q+o4uD/TurObELzZMB0i/iK688rfbwPoR3F8ZtrlbkuvHGmwvvglRexm9jSXRn
         8TiZ9w2iDqDnZ9VmgMCq9l2D2laIZ1UkOB0O16fTjx2CBXi1Qir53oq1Nd5ddJGleNga
         YiBXyTkKkl5greQJQvToGjSTuy2cPchNNWWuSZZHiFDvQUIN1YN8omBZMyZahwSXyL1o
         QoXP9NyH5FCWvnZHXRvfWfTM8gJX6/ZiY91hR82FMaOb7VHvLGpcYuKHHRT6LZRePriF
         U8bJid35bBAEjYAIQe+Jux+5mISgQaL2pAdm18IeKf4kB9QHvaVT/NGWhRq9QwBIyebI
         fpmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=idRrgLQbh43uv5SWzcGBZ8Bw6NnS0EFw56f1NhH2bmU=;
        b=fsJLv67UStmJqnciBEWM0UQ9hQYJXqsqVZeZmD6ye5ewYb1hsN6/sAleoGGYKHfjV3
         mSkTUSMJspJsbGp6TfXiWqVMJDuQ3RJImR5S+ZRekr5T9TY5lp6VYnTtOmXd39AA8NEW
         bWFI4GYS1SjcxXGiFdBb7ahSGzOB8HF98ARBlnIci6CWY/qlYvoGIu9nutIiwfjREROt
         ETo41Up5R9cxiLSUNoIP1v9UQbBsSI2i4o4AHpj0fJEFlaAXOXzhAhsmmSARqHzatXg8
         jPrW9JKTQoGuaens1BGzLzcAuJrhuTDcRoLZMb5VBUkLIpHepkc9MR6pjAAxEiO0MIyv
         J04g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jyT0I88f;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t79sor13366197itb.25.2019.04.12.02.48.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 02:48:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jyT0I88f;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=idRrgLQbh43uv5SWzcGBZ8Bw6NnS0EFw56f1NhH2bmU=;
        b=jyT0I88fbQsWDDkcpAHsTB4dPiS8GXwBOaA7w1gX7CjhR5ckSeSU3vVufWyzwg+S1N
         UN2mADQzD8sYoaoJ9PMXtIZvU9Pq2QtBBnB0TjjHxTRBT00PI/PoAMEGY4qfBOZCpVey
         rLyvgs2FNrUjDQLKpuUJpv20nwwQj6pptaATym9VKQXuRRcTXltdZLhyvxT48v9rGNzq
         DEWcgU1eskhuQUdnKN/S+IC6lyTtrL4mwnD92XJFh4F2kMZ+E3dFBS8xyKggTLVezoye
         tOPShNTuGAvY1GLsvlrCmhKwxxrzan7jyRZndfVAt7BdldLN3kkCRji2xVSctdnLvzvq
         i0EQ==
X-Google-Smtp-Source: APXvYqxjGJJ/A6mt8SH18qyn0SuldDTOBgOjI9JM7PPodXcwvazbhCWq4k7iNxWIIZuEny97Xt+vxPg9cRU74KaHymM=
X-Received: by 2002:a24:5751:: with SMTP id u78mr12491332ita.135.1555062523330;
 Fri, 12 Apr 2019 02:48:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190411122659.GW10383@dhcp22.suse.cz> <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz> <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
 <20190411151039.GY10383@dhcp22.suse.cz> <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
 <20190412063417.GA13373@dhcp22.suse.cz> <CALOAHbBKkznCUG39se2wcGt9PZYiGFhCm9t2t-X+CL5yipT8cQ@mail.gmail.com>
 <20190412090929.GE13373@dhcp22.suse.cz> <CALOAHbAcXDDdq_XO+hvwTq6PMNjFFgHAY2OPmkAReKV8-wR6sg@mail.gmail.com>
 <20190412093641.GG13373@dhcp22.suse.cz>
In-Reply-To: <20190412093641.GG13373@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 12 Apr 2019 17:48:07 +0800
Message-ID: <CALOAHbCh6NoL6w3KQ+a=i1JhqnYKK5sgspQeUaCV_iPdEu5X9A@mail.gmail.com>
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, 
	Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000033, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 5:36 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 12-04-19 17:29:04, Yafang Shao wrote:
> > On Fri, Apr 12, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > > Then we can do some trace for this memcg, i.e. to trace how long the
> > > > applicatons may stall via tracepoint.
> > > > (but current tracepoints can't trace a specified cgroup only, that's
> > > > another point to be improved.)
> > >
> > > It is a task that is stalled, not a cgroup.
> >
> > But these tracepoints can't filter a speficied task neither.
>
> each trace line output should cotain a pid, no?

But that's not  enough.

Some drawbacks,
- the PID is variable, and it is not so conveninet to get the tasks
from this PID.
  i.e. when you use pidof to get the tasks, it may already exit and
you get nothing.
- the traceline don't always contain the task names.
- if we don't filter the tasks with tracepoint filter, there may be
lots of output.
  i.e. we always deploy lots of cgroup on a single host, but only some
of them are important,
  while the others are not import. So we limit the not important
cgroup to a low memory limit,
  and then the tasks in it may do frequent memcg reclaim, but we don't care.

Thanks

Yafang

