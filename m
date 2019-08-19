Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E311FC3A59B
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 08:15:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F6282085A
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 08:15:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b/SKSOE5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F6282085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44D8F6B026A; Mon, 19 Aug 2019 04:15:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FE016B026B; Mon, 19 Aug 2019 04:15:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EC5F6B026C; Mon, 19 Aug 2019 04:15:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id 091316B026A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 04:15:46 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9E40F181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:15:45 +0000 (UTC)
X-FDA: 75838468650.06.snail38_4f57b56e58231
X-HE-Tag: snail38_4f57b56e58231
X-Filterd-Recvd-Size: 4242
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:15:45 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id o9so2346274iom.3
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:15:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pXbw1jr/ktcCZdvTIpV0s3lmPo3LUoI6G3jiyiEFOb0=;
        b=b/SKSOE5GYuU9aN0Oy2xKGCYMVJifdPmTpP4XkZciQmZ5qqjurQxmY+uug81rBWK4k
         +g37Vi61xCB/LIgyyp5VLlYtzGOhgs3G8DjJLhdBVHbwkPbkyQTgKK5A6hI1jlLxG7YN
         ftVdwHpjQ6njXN77a72uEzLyX7pdVWUgAu51r4SMfLtTZlP4ulRd4qFOH/YqaZHtLn/T
         BUsUjjIZyw+/gc+yv2vYW1t0dlLrEpkpvKVpEwuV9TXPT30RYVJfHr69axynFxij8nya
         l4LGf48zrphW+HFIqYffpf9nXmdugPD47ECaXlatkyc7tjqy4QPUrbUob6Ft1l9XakWv
         Ud+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=pXbw1jr/ktcCZdvTIpV0s3lmPo3LUoI6G3jiyiEFOb0=;
        b=M3x1nb4BJ7uv+MxMZLqd0yy8R+NIYD/KxSb0Ux08s0RbVVPVpQjAeLXFqY2qLX70qh
         dGuBEIHP6OoWnCnRXgwsAkUxAwhiopU7oMAF/W5jDFUgs5jBJw8A3ifGgv/ZFVMlo3N3
         +BnEqUIacDYvIwchqD3qVhtT6/URG09TKk4I2c6SD5eLXKV3FiUAhcL3TueRYIYP61WK
         TqIc6cPjar6w+tK4+Ykw1ig71ELJP6HzCKBFFZjGRycSyo5uXWMwN9WxzmW3aqzjw5wh
         PUA0H3J66fLmB1zmMZ66D8HGJj2gBJbzoiX6SAchRWBP3tVcu1cc4qxsB76WtwSOIVFS
         KNlg==
X-Gm-Message-State: APjAAAXYyBPGc9oMBWwiDGh+p6DMW/+n3NXeAakQBg3t1wqIjTr9iW+5
	ePWU1EF+es6DwngAGQCTRPYL6ge6sNgZsPlwGLw=
X-Google-Smtp-Source: APXvYqxL7UwG5hy2u8CtG11rZQGmZn7iTKBQtlMW5XVIITgKYPrQ2TW9lfCh0PecltKqEoTpBK9xrmMEfJB2CxpVONE=
X-Received: by 2002:a6b:e511:: with SMTP id y17mr25241550ioc.228.1566202544448;
 Mon, 19 Aug 2019 01:15:44 -0700 (PDT)
MIME-Version: 1.0
References: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com> <20190819073128.GB3111@dhcp22.suse.cz>
In-Reply-To: <20190819073128.GB3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 19 Aug 2019 16:15:08 +0800
Message-ID: <CALOAHbAo2MLkavFZz_5f5hvXE8BzYW8R-yjw5acnwT315TxoMQ@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: skip killing processes under memcg protection
 at first scan
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Roman Gushchin <guro@fb.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 3:31 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Sun 18-08-19 00:24:54, Yafang Shao wrote:
> > In the current memory.min design, the system is going to do OOM instead
> > of reclaiming the reclaimable pages protected by memory.min if the
> > system is lack of free memory. While under this condition, the OOM
> > killer may kill the processes in the memcg protected by memory.min.
>
> Could you be more specific about the configuration that leads to this
> situation?

When I did memory pressure test to verify memory.min I found that issue.
This issue can be produced as bellow,
    memcg setting,
        memory.max: 1G
        memory.min: 512M
        some processes are running is this memcg, with both serveral
hundreds MB  file mapping and serveral hundreds MB anon mapping.
    system setting,
         swap: off.
         some memory pressure test are running on the system.

When the memory usage of this memcg is bellow the memory.min, the
global reclaimers stop reclaiming pages in this memcg, and when
there's no available memory, the OOM killer will be invoked.
Unfortunately the OOM killer can chose the process running in the
protected memcg.

In order to produce it easy, you can incease the memroy.min and set
-1000 to the oom_socre_adj of the processes outside of the protected
memcg.

Is this setting proper ?

Thanks
Yafang

