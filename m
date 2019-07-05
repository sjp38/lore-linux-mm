Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97578C5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 09:42:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CAA120843
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 09:42:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BMk2J+ME"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CAA120843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72B96B0003; Fri,  5 Jul 2019 05:42:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E227A8E0003; Fri,  5 Jul 2019 05:42:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D11C68E0001; Fri,  5 Jul 2019 05:42:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B08796B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 05:42:21 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id w17so9230632iom.2
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 02:42:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EcKFkOoZDjGrRZLQwPcj2xSPXakFZalLNCV13tcflgY=;
        b=HFIhHJZbK2SrQDN2neIwKCHYMRc2jXbw1fsTK7zSxbJbrGaJP7UXQnrN+9UjP4OAaA
         J1LsoC+LhGQxDi2xdf/Z5vtqtQLEbrE0iuZNmjVtcP9vr6kL98SOfjAlQ3GY/Y/5uscr
         7MpPLaatMBDID149PnMf9kgk20pPHDnh9jXIIkGB3nj/CUt7qD66hnFFH07EJU7G7cSO
         gVFAFaAanQ2Aa6PAuGkMl09ae6DlFgu+Roo7xTkXJ/+KrofNydHN/uZNWtDkDeC1q6qy
         eKdqHrqJ3+ssqlSjOMsSrEWtnnhxIEkVTzy6BQwY0GgqRe6KC0QWDmcJGG6BblqV1Si4
         zPag==
X-Gm-Message-State: APjAAAWhlLx4ssMxz1bDFre9HKjrWybaWAgplvkoZdK4T5OGlY7zB+sA
	J6dAvRXfMUqB/WxJIjusG88gMev9kryekIEZOVNcWhMAiBP7mUTIGcn7tMIaXF9GLiRQNauSo1x
	GdB261mRssUFIpBzcOJodu+PKeYv8SLGmP6jGuXnJFb/TVhrz61hp9ufSYYHfqJZvMQ==
X-Received: by 2002:a6b:6209:: with SMTP id f9mr3270596iog.236.1562319741455;
        Fri, 05 Jul 2019 02:42:21 -0700 (PDT)
X-Received: by 2002:a6b:6209:: with SMTP id f9mr3270546iog.236.1562319740599;
        Fri, 05 Jul 2019 02:42:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562319740; cv=none;
        d=google.com; s=arc-20160816;
        b=1CYEE7ItZhc+ck6AXPo/uy7EEC9n4rbOMe/Xhjd3PFR+/XXuiMtIurSti/Be3svLwD
         14NEyh8HYN86NtCHt36mKoaE9qtiRzSc5ABCMLmSNXz6hn6qBWtDcUi+KhMcfW2WapVA
         5Wv5TmAVtvNnfhXX6v9YyuEPil/qq0wGx/+x8xyF07GS4Tq1Hchfx3OiT8CW90kaJ4B1
         rg35ZlpOOcw2ZxVGRq0/tsimk5YWI2YtFKgH+8txIs9DmqTme9EfmXHUPBMIKkYr/iIX
         GtqX0EM6tWLRSOroWle2o0qTf2a1z2+bbBBexK2EfeLjsPrWhj0KIfwFHesAxBCIsqYL
         q6Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EcKFkOoZDjGrRZLQwPcj2xSPXakFZalLNCV13tcflgY=;
        b=b+TqlhKeiHFwJ6RQ/81SVvBEZwIhIq7JE6pNaIxlQbqj3R+cSjBBPHw7nimCMxbMkV
         gDYMgUngPhOkA6RW3sFRmyrcN7GwqHUFHazxTdGmwAoe5nyo+ZoaA2X0bQnsQEj0ajkD
         /Q72PFYXFdk+kFd55Mpl1Isit7N6lIMRmAXbZLp6tqN/wr88rtDY7IIPDP7kf0sWGDd2
         vx8UnwU5g/uY+mn6OCealQWcjc+wll3hShV7YQz9m/Uq0jFXtzzh5MfdocrNSJqVgVSy
         mhl/H1dSjhYJKpF0wybssK7aX9LEz8kNDPHLAO+9fBqTULiBfRuVoPu1CQvzdGKSjWOK
         8iJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BMk2J+ME;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m187sor5883561ioa.46.2019.07.05.02.42.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 02:42:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BMk2J+ME;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EcKFkOoZDjGrRZLQwPcj2xSPXakFZalLNCV13tcflgY=;
        b=BMk2J+MEY5lmwPLzjSltNxXm2ogjJN1ffQLSM8PZqBa4uBs8NTM/lDwlMqMyetpB1r
         XpJpMpGgVJseFgAg9a2kDXkKbByPnQFTTPJfq0/w2GmU1Oz40YuGHN/lFnvmW2S8f6rs
         riiI8i9Zj1BzpL4kIqFKoYwSELG7GK6LwB+0mep3wfcCNNBwUEG5RQ0mHZlPBt+qDzol
         d9ZRCpE6vxTQ0H/gVU+1ZyN7qDVFk1bE2swiMHB/LkxMvihF4/iP19KIz7tt7DdxgvUt
         W/Atu36LFBWrxojn7pMsNp7gXgCRUX+nSZWgRG28UbrOVfReDMPGX4emnbIObj7RhhRn
         J0Bg==
X-Google-Smtp-Source: APXvYqyWKVrjPPzFsp7PeayE1AXAL04Blo/1TvkTaQ9Pk9DL5TevyzL0H0gasqykq26o7t/QlmiNHRTke/LFOz9TJfs=
X-Received: by 2002:a5d:8451:: with SMTP id w17mr3334658ior.226.1562319740081;
 Fri, 05 Jul 2019 02:42:20 -0700 (PDT)
MIME-Version: 1.0
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com> <20190705090902.GF8231@dhcp22.suse.cz>
In-Reply-To: <20190705090902.GF8231@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 5 Jul 2019 17:41:44 +0800
Message-ID: <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in cgroup v1
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Shakeel Butt <shakeelb@google.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 05-07-19 15:05:30, Yafang Shao wrote:
> > We always deploy many containers on one host. Some of these containers
> > are with high priority, while others are with low priority.
> > memory.{min, low} is useful to help us protect page cache of a specified
> > container to gain better performance.
> > But currently it is only supported in cgroup v2.
> > To support it in cgroup v1, we only need to make small changes, as the
> > facility is already exist.
> > This patch exposed two files to user in cgroup v1, which are memory.min
> > and memory.low. The usage to set these two files is same with cgroup v2.
> > Both hierarchical and non-hierarchical mode are supported.
>
> Cgroup v1 API is considered frozen with new features added only to v2.

The facilities support both cgroup v1 and cgroup v2, and what we need
to do is only exposing the interface.
If the cgroup v1 API is frozen, it will be a pity.

> Why cannot you move over to v2 and have to stick with v1?
Because the interfaces between cgroup v1 and cgroup v2 are changed too
much, which is unacceptable by our customer.
It may take long time to use cgroup v2 in production envrioment, per
my understanding.
BTW, the filesystem on our servers is XFS, but the cgroup  v2
writeback throttle is not supported on XFS by now, that is beyond my
comprehension.

Thanks
Yafang

