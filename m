Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B457C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 21:18:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 004D52075B
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 21:18:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kOUhQs6h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 004D52075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6340B8E0046; Wed,  2 Jan 2019 16:18:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B9B28E0002; Wed,  2 Jan 2019 16:18:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45A5C8E0046; Wed,  2 Jan 2019 16:18:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 136B18E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:18:34 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id l7so22828806ywh.16
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:18:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2stP9UFtPAKH3/LwOn4Ye9NZzNGkHMYFwKnAD6NZC3E=;
        b=agIUR2pk3quNq3OcUXUGDEBg53h+exmWndG3rkyTuEOx1XulBv4q9J+sox++SFRIxe
         6L0PpbTqwcjze5xHjMZ/CtD9qj0+7mHEp2qO5S9BfzWQ7FdQ2u6JrboVyEpdu+TXNmsF
         szaHodWtsEwPWYY0FlmO1NAfyWDyrRe9cewxTI3+ENRyYo0rBTWFITnML7em+H747Fvw
         eFPErWzsN6C3XZIwFkk9iUEDKejNLbNQ5rFhSVSDp1P7wQIPbCX0fm/bFKx4l93j/vw+
         2oUyfCgePJSzl49K7SdCPP9rIKl7HZ2s/9OjllGMhA0CMwhqdssPVjQ+hhxpgDvekT4U
         vq4A==
X-Gm-Message-State: AJcUukeX28SMD5Mvaf0HbEbbYIWsw9bJABZSkzXjjWl1TcAuSaMd5f6W
	LYNao/x3nXeRl61TIcLrqSpxYSNYZzC5AMW49pcJjVA30z2ystvTRrQG1Gy66tNVYmmLHWOlfuE
	5bRqwlPmIEK8LQddJ2Mx6D4jRSFVzf82F2HY4RstUzpmfWvdFXqpQoYXoohDfdoZE2MpnRuu12C
	vH2y56DeQmapbEz/akcRvCaOBavTdcTI0r9OACTRtn9nrHy3Jrz4u3XHIN3MKzDcSv0B1oHV/nm
	anLDFmghqS6klJA9cvRv+iNkldUTwRvBiU/LBKNlwFDwwdQjZ07Z08HroX7GecZAnvhe3KhKo66
	h4aqCjkmRM8Wbf4F568bRyIqZxshQyc9mWwqeHRhreiGuAWsB+qT2mXDJEtn63mbqkqPp83pO9b
	l
X-Received: by 2002:a25:5f0a:: with SMTP id t10mr38356557ybb.203.1546463913815;
        Wed, 02 Jan 2019 13:18:33 -0800 (PST)
X-Received: by 2002:a25:5f0a:: with SMTP id t10mr38356534ybb.203.1546463913147;
        Wed, 02 Jan 2019 13:18:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546463913; cv=none;
        d=google.com; s=arc-20160816;
        b=vkQBooXXLHDiySTrJ5unfwj5MsQYK/rBXugh5WvW4bPoCOm5SQW1YzAYDHuEy6wdbW
         T3NlTXm+kYmnSMIHIKUZnFyS17R2Ca4Z306D8VTDmvMvo7y73kvGfVqPwJ7I5nNweygp
         ncKZrLnxAQGvKX53c4gzqgp9DMJkiZB8GcxzwOtnggRCdIh0XSE4lG7T+V9ecMHEPMt1
         1usLKd38sDJiEgKyM/yrWid7tGdlTy5nsqnq8HQuDpDFhPtNodtPUZPvI68JRrraCzf2
         55fvR8r6zhTq68cDn6qgGQf1DAec3WEJ0Bfv+11o2GSsi+9jYCt2Kfvh444LSfPcmyC0
         1fbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2stP9UFtPAKH3/LwOn4Ye9NZzNGkHMYFwKnAD6NZC3E=;
        b=CyImJrvVsOr0QkFIKk0mFkA9zqFdi4Jj3Dr4nqtcWBYwLJn6HDnW8u3QRHk3HuU7i6
         7PLczmpr4zBMzolJtACuaWewBrrtIYnBVk+eJVU2cthsn7gUkK3qSjFi2zxehjhisfkY
         5bVs/2WbKHVjkF2jYK97UUlhZ7gKJWueKYTtU2+APyRAztvB8PI+cCz2JqzXnKp30P2U
         p2YNSJ8d8F0Vk3us53tWu2ZKde992JoAlLe+Ao8+zfpXXyPaSk+3LnbyVyI9kKZJ2gjL
         7DYtpWtN3B3d4QdfXpSHFM+BWqGQOPfxZFKt72g2eiGcmj454pai4afaSoHGg67Dd3Pu
         OxlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kOUhQs6h;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f124sor6985064ywe.27.2019.01.02.13.18.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 13:18:33 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kOUhQs6h;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2stP9UFtPAKH3/LwOn4Ye9NZzNGkHMYFwKnAD6NZC3E=;
        b=kOUhQs6h4jhZE8Kh+U6zRjNcWfD5sr/T49F6y9WimfogeFHtF0GGdh8jjyqX03XLx5
         0vTrglcvnn1h0LPCyiKLUyYCRKxsXdgSNb7Nz5U++evrIA3ZT4DLbCC9HOdkk2EbFAwO
         5iHNtjls7Vt3YIzINaVlmiiqcXkHRKv6c5QaEsEoKGHem8qiq9pxW5Q8F2+g9Jd6pf9X
         nk3KaTMcNhObMJ4VflMSeNfzyv6Fet7szZtgXIN7CoO75YBpe+hQObSPe+rdmc/RKsQn
         D3R6Ch3qXRXtadJRfWAn9PNBsceFvyD1vlPXxwpsDdcyErmfNB5fx2pNc8eA8ExBOJfZ
         6G7w==
X-Google-Smtp-Source: AFSGD/WeHteSWiTWipjnMVwfeXXIYWceoEsVLF5g0YXiF+BcfqAimEQTjK7InaWTmRnpKaLSJ7ubnMApdjUlVoWHi/A=
X-Received: by 2002:a81:c144:: with SMTP id e4mr46830352ywl.409.1546463912552;
 Wed, 02 Jan 2019 13:18:32 -0800 (PST)
MIME-Version: 1.0
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com> <1546459533-36247-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546459533-36247-2-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 2 Jan 2019 13:18:21 -0800
Message-ID:
 <CALvZod4yYJ7SNrEnpUFwMmaUaaaLgGFr199nqra41vidCPsB1w@mail.gmail.com>
Subject: Re: [PATCH 1/3] doc: memcontrol: fix the obsolete content about force empty
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102211821.T4R7FmuBpLNE6SpOXjRR7kzJLIM4-yhBfWooQXFM2Tg@z>

On Wed, Jan 2, 2019 at 12:07 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> We don't do page cache reparent anymore when offlining memcg, so update
> force empty related content accordingly.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  Documentation/cgroup-v1/memory.txt | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> index 3682e99..8e2cb1d 100644
> --- a/Documentation/cgroup-v1/memory.txt
> +++ b/Documentation/cgroup-v1/memory.txt
> @@ -70,7 +70,7 @@ Brief summary of control files.
>   memory.soft_limit_in_bytes     # set/show soft limit of memory usage
>   memory.stat                    # show various statistics
>   memory.use_hierarchy           # set/show hierarchical account enabled
> - memory.force_empty             # trigger forced move charge to parent
> + memory.force_empty             # trigger forced page reclaim
>   memory.pressure_level          # set memory pressure notifications
>   memory.swappiness              # set/show swappiness parameter of vmscan
>                                  (See sysctl's vm.swappiness)
> @@ -459,8 +459,9 @@ About use_hierarchy, see Section 6.
>    the cgroup will be reclaimed and as many pages reclaimed as possible.
>
>    The typical use case for this interface is before calling rmdir().
> -  Because rmdir() moves all pages to parent, some out-of-use page caches can be
> -  moved to the parent. If you want to avoid that, force_empty will be useful.
> +  Though rmdir() offlines memcg, but the memcg may still stay there due to
> +  charged file caches. Some out-of-use page caches may keep charged until
> +  memory pressure happens. If you want to avoid that, force_empty will be useful.
>
>    Also, note that when memory.kmem.limit_in_bytes is set the charges due to
>    kernel pages will still be seen. This is not considered a failure and the
> --
> 1.8.3.1
>

