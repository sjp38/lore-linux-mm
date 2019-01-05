Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8565AC43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 00:43:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DE7E21872
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 00:43:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R/IYiBRY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DE7E21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC80B8E0115; Fri,  4 Jan 2019 19:43:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B783E8E00F9; Fri,  4 Jan 2019 19:43:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A66DA8E0115; Fri,  4 Jan 2019 19:43:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 762608E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 19:43:35 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id p20so13268485ywe.5
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 16:43:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=snHqLQmz4nt+VNG034zl1FNOGYA7ZEBfLYfuKiNvzvE=;
        b=oJGmWFH0wwIRNZMu9hn9u+mcGnu15JhHe29JkBr4y48R8Pzhnrbdbn3clwsXp8rd49
         aI32uATyQ0pPCuXZQu0JoNTi7b/xNKHvdIA4C7SDPWQV3nY+tC5MGrog3fmRcFS2WxZE
         V8nS5ROCkP1mAU0/WEWoR9euJTRrOYxZ3/03Hl4UuGxY+BbMn/wfYZ1NsqTY6J3d4bXs
         x1ObOQ5+QobnAdoP8gxX9EVRdDVwBQ+WT3bMWRQcxGpz20+Puu1QxFstmHfumh+gbwtC
         qzDsM7dpc+8Dok477bfpnn5QWzUrJiiTuYcQamAMKYj8V5jEq2Cf7ApfsdJVVk/K4hA6
         MTPw==
X-Gm-Message-State: AA+aEWZp+xHtI+laOHdSbtGc3VPgdKVpbK/ltcmoV9DNpM62TykgTBFl
	aUuyCiol9CG1THLEDSTvLR+2+mXa2zk8QP2ydxG/NR0iSuoGh5oDPDtCax+KtFMmtdFYp1Y8SB0
	Rn6TzEP/DYHAWC07XFpxuvxlGZdm2m9/vU/b7vCdftep/RKQMlppAAmD0sX+mZ9dIb+vQIsw556
	xCUKPVV2Cc5L2K3lvEq6+QNvUcIn+V394Vrb3siJ1HYqruv0A1WKKRZjDHD0cixYkBr/vH5DG9V
	WWndHEJhQMlNwtnqueK0SgjfuTtr3o78h6jUcUKUBm+g3W/JVI+JDKKBUbUG0f9/t0EHut2u97r
	eYVqU5nANv4s2ra9EgCkp0oIK7NVgVXE9fUlelJ0jpCnZWojnB7gesJsFJ7npAkoVbT5K+CFBEF
	M
X-Received: by 2002:a0d:e505:: with SMTP id o5mr54172212ywe.38.1546649015100;
        Fri, 04 Jan 2019 16:43:35 -0800 (PST)
X-Received: by 2002:a0d:e505:: with SMTP id o5mr54172187ywe.38.1546649014455;
        Fri, 04 Jan 2019 16:43:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546649014; cv=none;
        d=google.com; s=arc-20160816;
        b=GEwO5Ealf6QeV+X6iSl1FGAaPBxV3/SSL5BEw5i8NM4COX5OWG6fQsBMgF6eVyg2oA
         g9nK2ifRjflDzwff09BUInvrxga4IPCJTw4e+EQzC+0rITotot8izapqLQoYfiyOoYT0
         OthoGFycBymA4JFzb0MQcmSt3Srz/IXjJgrCoNMM6y2OlvWAw6Fp+pnx4Z+tGuH3U+j+
         U8TBLeKrjVCZmyqB7GvIujB6Q+RsDtmxOVpqswd/5nkjvCZFkLkqGHzKziJcAxlV2CJT
         bF77JR+FojVBp1fuqIBdr3ifQ4ulAkNpc7g6kt8GSrU44RdS+4w6kC3BawP098nf17sb
         ZI5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=snHqLQmz4nt+VNG034zl1FNOGYA7ZEBfLYfuKiNvzvE=;
        b=tvUf3jce5XpPUGOysb1Vjf089cIFI5h5PH7dSnFIGe/UNFbawCc7sYWeCnmzb213TX
         kqkjYGwcUZzOlTgkiVgGR+TmQ/FXhtXIxutl5YBOXVQjeU+/JTW8rdExB8H/L8FYQXfb
         pRHcRJdZt0HJrJ32w92Q1ohUbWZky7KbJUObrMECDMjWsJAlYmz+1ouD7LvFBb47QUCK
         +D5JERDUro3tUeaKx0rjWcd73j2U2jgNY5nOghUkgEevQSKR+SwTfISHmDPali3fxlB9
         NX46HCX9sWtt9mKalOYviq0kFkyLnTK9QPk7w4K7UaEM093Rn5lmZIF9poUFwhZdSTZE
         gQng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="R/IYiBRY";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor13455517ybs.196.2019.01.04.16.43.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 16:43:34 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="R/IYiBRY";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=snHqLQmz4nt+VNG034zl1FNOGYA7ZEBfLYfuKiNvzvE=;
        b=R/IYiBRYG+40WnMu2AApy0CGvAWBAXw3LLoHJhw/4mdSbXpsJqLtNIo2TdL28mKP2R
         jBdmt2yPvZH9c+sP9Gl0idk7S3bG7lO40H1TIFGD+FTiruxX2opueuOv4XNFU5saRzv6
         YJveZFBkl9SohMJxX44nJJNQirz7B6bh5plb/jFTUS2APj2WQ6fgZbglZ0eBoSrY5nzy
         LxTprWV6t7i/bDlhHN+Y5UfRIl3tcPTbtEuUh5OVRhboWUXx7sSz0YyB9dSSGqEE48au
         qxhMzGAyXhNVFr5hPA2d5iy4YvNHf+LuEPa34dSo+Vaxr9uzcmEN1v44fCeWaZuPmRhb
         AAwg==
X-Google-Smtp-Source: ALg8bN7TM7HkFVP1EabeeX+prME1evMFy5HlgmxrURWGtISoIJw7J0auA1L+qAdydzGRcW7HuUvxmpPE86nTUj9QCKk=
X-Received: by 2002:a25:2743:: with SMTP id n64mr21202102ybn.164.1546649013690;
 Fri, 04 Jan 2019 16:43:33 -0800 (PST)
MIME-Version: 1.0
References: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com> <1546647560-40026-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546647560-40026-3-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 4 Jan 2019 16:43:22 -0800
Message-ID:
 <CALvZod5Fh0K-JKGPH90c+ONBSTdwo7Z8fUyyAMen=ZDzPqTAXQ@mail.gmail.com>
Subject: Re: [v2 PATCH 2/5] mm: memcontrol: do not try to do swap when force empty
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
Message-ID: <20190105004322.jay_cDoo_zaoAmY8-In0Q4bVQr_a4XqQYWKhO7EkNho@z>

On Fri, Jan 4, 2019 at 4:21 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> The typical usecase of force empty is to try to reclaim as much as
> possible memory before offlining a memcg.  Since there should be no
> attached tasks to offlining memcg, the tasks anonymous pages would have
> already been freed or uncharged.  Even though anonymous pages get
> swapped out, but they still get charged to swap space.  So, it sounds
> pointless to do swap for force empty.
>
> I tried to dig into the history of this, it was introduced by
> commit 8c7c6e34a125 ("memcg: mem+swap controller core"), but there is
> not any clue about why it was done so at the first place.
>
> The below simple test script shows slight file cache reclaim improvement
> when swap is on.
>
> echo 3 > /proc/sys/vm/drop_caches
> mkdir /sys/fs/cgroup/memory/test
> echo 30 > /sys/fs/cgroup/memory/test/memory.swappiness
> echo $$ >/sys/fs/cgroup/memory/test/cgroup.procs
> cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
> dd if=/dev/zero of=/mnt/test bs=1M count=1024
> ping localhost > /dev/null &
> echo 1 > /sys/fs/cgroup/memory/test/memory.force_empty
> killall ping
> echo $$ >/sys/fs/cgroup/memory/cgroup.procs
> cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
> rmdir /sys/fs/cgroup/memory/test
> cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
>
> The number of page cache is:
>                         w/o             w/
> before force empty    1088792        1088784
> after force empty     41492          39428
> reclaimed             1047300        1049356
>
> Without doing swap, force empty can reclaim 2MB more memory in 1GB page
> cache.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index af7f18b..75208a2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2895,7 +2895,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>                         return -EINTR;
>
>                 progress = try_to_free_mem_cgroup_pages(memcg, 1,
> -                                                       GFP_KERNEL, true);
> +                                                       GFP_KERNEL, false);

I think we agreed not to change the behavior of force_empty. You can
customize 'force_empty on wipe_on_offline' to not swapout.

>                 if (!progress) {
>                         nr_retries--;
>                         /* maybe some writeback is necessary */
> --
> 1.8.3.1
>

