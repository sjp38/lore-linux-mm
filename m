Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC4DBC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75CD42080C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:17:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Q0zhknit"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75CD42080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11C436B0005; Tue, 25 Jun 2019 14:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A4DE8E0003; Tue, 25 Jun 2019 14:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAE718E0002; Tue, 25 Jun 2019 14:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C409E6B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:17:17 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id l62so23576780ywb.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:17:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LV+Pj0XizZBoM+Zg/sXCVKPC66eQENrb7Ey4RHKp69s=;
        b=jCXDTg5GLa4GtAGRctdzrynO4Ge2rOPOd7eY8j3pBk1mDH4ALss7ZDEXkG+lUmcAsX
         Dnl0IwDiA/mTCG+m57ZsmRqAEZoqmRFz+a/9c2PjVd7fwvRQDButiVvFIxiLxULIpuXn
         zMPcNVPq8ybbH8y+7eB3crkSc77QdQymMNXNPbZAPcj1iY2deXUO9YgNDRNQbasSKuCN
         o7aJDU3xzuiKI5d8/eCop1MumbIf6RiReSSBwAMQP54oCTUXnppVyZVqcsysHpihhiZT
         tB0GJD4afffaOlfRVZWD72+uSiGjvkO2aHokmoHIeG+oaPc1sk+RbbzXKggn1xz3HxJQ
         4DaA==
X-Gm-Message-State: APjAAAXSRjmayjq3OPgHoEKTjfC38byu08AUGxU1+eqFqtxKUAmtsefA
	cop2V3z0WGhcD6fY0EW6cOAbGMLi3dnVkRd6JFwoycXyVKu1o7w0QzyFGI5690vIzlBvude6plg
	n5iaAodszRiu8R+lABJ/P9rXxCE9b6Bh8tOHeTPwU20sdsSkUF69HAxhcDEiiy2Uksw==
X-Received: by 2002:a5b:510:: with SMTP id o16mr24603495ybp.443.1561486637526;
        Tue, 25 Jun 2019 11:17:17 -0700 (PDT)
X-Received: by 2002:a5b:510:: with SMTP id o16mr24603465ybp.443.1561486637017;
        Tue, 25 Jun 2019 11:17:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561486637; cv=none;
        d=google.com; s=arc-20160816;
        b=y1yj9ulMoBN9QUu4jyb2RLLRno3T/JiRlMEWul4Pxp9+oilV6Nay5L5Kq3OCS3Gg8z
         0rAVzFw09mm8fULoltftb6wRKTgdjv25uFr8ZZOQZXba0BAMrVBrhnqmV5aSDLpaZ1Ys
         +CIkn5opEnaVSXEg7thxEqlCunVOxceDVQFShFEcXwszWPAVOMHVNT+a6SMVoDk/xcao
         199GZlmoDZyFvH59qHSflv8hVwA09JC0IDt76pzEMzXga6ZVGWbLUW1IJbtJCqz8OFd6
         3IdcquD+/A3mXhuFHJN8bqHr1lbiRWxY5ZkCX3TuGyjmhkEFcDMLrZ5qWdN/iE9In2Yy
         otww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LV+Pj0XizZBoM+Zg/sXCVKPC66eQENrb7Ey4RHKp69s=;
        b=Lh7wbvC1Un4iS05OHHinF0MNocIFzEHx8lWfTKKdiW2VmvZnBzRY68lGxR65s0krS+
         +ggyOc2HQJeWbwt2k3kSiwWMtkRFvWg5SE5utNziI80tESRrQeyfKGvh+epsTlqHDnsn
         tFtisodVyEFLX+COMjqDTdjuSmeScN6rizQYLLDg1vQSdqjcxLOkb9xbSU5RZrr3XorK
         fYHLnnTB1inPNqj2auEOC/cfsFr/orYNzdN7wo6cb/GAB8v0LhUc9rhhyO0hkkZqxPjb
         4MVwsWRy1ohPbHzlaOr4Yezeav2Bbs9AEneJOhKKED3I8iKZ1v2NubtS/zOT6X6+C10l
         tJdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q0zhknit;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor8593433ybq.163.2019.06.25.11.17.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 11:17:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q0zhknit;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LV+Pj0XizZBoM+Zg/sXCVKPC66eQENrb7Ey4RHKp69s=;
        b=Q0zhknitW1nMpsuYODap81b+Kff2FM//a6CrncKspkGXfz6ukAPtuB4vDq/ujO0Q4P
         Bsvo/811XJHJD4y7+vKLSA/Ir2MSraBJu1zfY7Ur/9MpBPG4tVWAqZ0jr0eO8XThScKm
         xkqUTB8U2/BXKwnxr8KaKQa0aN0JevXkYQ69KDF/7ktoFH4lAScTbmdbKfbbvpKrOqoU
         TR/V28hTfDInSozjEuFH6hvQG5RrZ7ArINs68zsK+twdmu9MvlXJ0/NGt9d0YeHILF2Y
         c/CInQ8UrQAjnUW8ZYJsWyQmUXrZMU1tGH5UpJoxnMPkgQzkmJRhTP3vClkIrGpwa82o
         lQZA==
X-Google-Smtp-Source: APXvYqyOBKfMA9lKTfCv08MGlGUTAUGGHiNLkjP3FZ0Jpmnx5mxfL+mlmmC/u6PckTvZybw780vm3EK1meJ5YTRbNwU=
X-Received: by 2002:a25:1ed6:: with SMTP id e205mr81985599ybe.467.1561486636279;
 Tue, 25 Jun 2019 11:17:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190611231813.3148843-1-guro@fb.com> <20190611231813.3148843-3-guro@fb.com>
In-Reply-To: <20190611231813.3148843-3-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 25 Jun 2019 11:17:05 -0700
Message-ID: <CALvZod41GMxCdsp_XSHSYAri5NpO5suimJ3y8D5=LLai2=qd7Q@mail.gmail.com>
Subject: Re: [PATCH v7 02/10] mm: rename slab delayed deactivation functions
 and fields
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:18 PM Roman Gushchin <guro@fb.com> wrote:
>
> The delayed work/rcu deactivation infrastructure of non-root
> kmem_caches can be also used for asynchronous release of these
> objects. Let's get rid of the word "deactivation" in corresponding
> names to make the code look better after generalization.
>
> It's easier to make the renaming first, so that the generalized
> code will look consistent from scratch.
>
> Let's rename struct memcg_cache_params fields:
>   deact_fn -> work_fn
>   deact_rcu_head -> rcu_head
>   deact_work -> work
>
> And RCU/delayed work callbacks in slab common code:
>   kmemcg_deactivate_rcufn -> kmemcg_rcufn
>   kmemcg_deactivate_workfn -> kmemcg_workfn
>
> This patch contains no functional changes, only renamings.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

