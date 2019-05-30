Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1885CC072B1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 07:01:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3FAA247CD
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 07:01:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uBMZGMO+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3FAA247CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 582A36B028E; Thu, 30 May 2019 03:01:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50B8E6B0290; Thu, 30 May 2019 03:01:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D3B66B0291; Thu, 30 May 2019 03:01:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1535E6B028E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 03:01:40 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id 9so259130vki.18
        for <linux-mm@kvack.org>; Thu, 30 May 2019 00:01:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Q1AVZODHTXqoipQTcM+k2pyJLkPC3ogLcgg1avCL8ws=;
        b=LKQFZNl4SOpbhGZ7uzqWModPVQicRJ4scTfs5pzS/nkiOeeskvttWz536DAi0XVvwR
         YqcmEXGmuPMIU2iiRA8w8QY5GRUkd9IoIIGoo7QbDT0PwHdblcjOon0FOeqOdQbqWB5y
         LSNRwelG+y2veWB3oNK+NM2jJFFvI01pvihFaX6BZt8SDFUsspJhYBfyi/4BTxt4+VZM
         UZ/ffhAKQ2k4520IOfRKnBpE0A5q2Hql0ls3inCmNHtn3gorBnnUGhC9vWLRVIk3k15g
         s75NIPcd+6Alko1qpdAAAhbJU7+LyZWV/2JSQCMN6x5YBKMWIbFZnQKtSo92pMYWLRTN
         hC/A==
X-Gm-Message-State: APjAAAXPJeKFF9P0sWJ1yHfLyLGSr/4aHqudaSgkkk0/pu6Z2HV0gFCK
	ZjfD13tIGb/VDkaYIkrpwJJPf+CuXXRgejlFMJHjvR0zyJZY5+bzydoGpNWKRt5JNnhRe6OgPa4
	f3uvFdqK5V5EBuiADWEVjZxD2Biy4iFZH7j9Q0s6ugx6vDFancHND0oEBNZjRnlpCOQ==
X-Received: by 2002:ab0:29d9:: with SMTP id i25mr926295uaq.43.1559199699726;
        Thu, 30 May 2019 00:01:39 -0700 (PDT)
X-Received: by 2002:ab0:29d9:: with SMTP id i25mr926268uaq.43.1559199699136;
        Thu, 30 May 2019 00:01:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559199699; cv=none;
        d=google.com; s=arc-20160816;
        b=xp5JS0zovYPK2YWWxXCSZkQxs4tFdsTO+FK8MT393rrsLgZ9MF9QSiPZEG2i6j6uy1
         d3Dy+e390t+kI4EFrdCtpgz1ZiISyqEgM3UH2zmFQiQp3HczGUXb1FzYYSzfhEtNGDMU
         hyHya9MaECpsLDFlJlgsC/JEsOou8JaTnFQZOe5VIM0qYSiYnIGZtYMVVR48WjjzgpoK
         F63AuddBAk0H85H/ptALE2jS2h6zPQotIoYHv2EZcRQ12As4UXWN4Po7GiEWnbwW46GN
         erqStBkVJBeNuvDxG8yXPE1x2YU5buKqVdDpH6YS5vgDqp0poQvktef0haNFzmkZsyVo
         DAoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Q1AVZODHTXqoipQTcM+k2pyJLkPC3ogLcgg1avCL8ws=;
        b=WQK4Rr6DJ5lyt4BHdI2HlvaJS2rrH8Wbza/X5gcdtiFKfe1eSPLgToEvydB2kK+ia+
         cjx0flaq6SSe1akdL32B66bczqyEqcRzvbL+IQWDJDFLQxvPORYJuD9YqNFKcsslmsgP
         4PT35ZbBrP999LbjG8MzujK0XqidwXSJUq7chLtR7zPa++2t5bqcomlUuPjW6BUp0cRq
         t5/wfZBszRKpXp9zHWdhRWO4jbq7f/zDF7kMkDmx8j/WTK72ARPeiooglgAttEQPPaGa
         gC1+YBa6zQzs9urvjdQHJ8+8lbFmbFl9RiQWltXTCwvJ4V6ptcVa9FZYB29PJmIKq8hb
         v8Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uBMZGMO+;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185sor882358vse.45.2019.05.30.00.01.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 00:01:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uBMZGMO+;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Q1AVZODHTXqoipQTcM+k2pyJLkPC3ogLcgg1avCL8ws=;
        b=uBMZGMO+qZsoCeRw3kwv3k0YCQqz0heCVI7dQyQhnaQFQ5ZilokWnv7NVtCi1n3603
         KCttYxV550rM84xbifejh3+nH1PU5HGaKhHDfo3cCBBpAgZFQ2z9OjbrTQlZ10kBqCVx
         O3tSin/t98cyBT9WfRD0LS94HiP9OmZtTWp96r2PF7NSi/6sPt7aIH8LifQyHh2w31xY
         r3BGguEr91cNp35qZY4p3JjNPrz/ikziz3UjVG1t+YOTJvoTb4jE9WuAewN8N3mzn5du
         ViEJY/Xke/XpBKvX9oFQN+iNAZtiUawVNxC14cY8LzqVWhbOPpV233Liw+XKTdMG8Wvk
         GHIA==
X-Google-Smtp-Source: APXvYqyDrKD/2h1wpy+U/GzxKvdJhWnVi3tIS5/8fKwMsqErxVDkOlmuINTDW+gtqY3qjgGWsBUMQTbVNCXJLkZZejs=
X-Received: by 2002:a67:f34d:: with SMTP id p13mr1054255vsm.95.1559199698948;
 Thu, 30 May 2019 00:01:38 -0700 (PDT)
MIME-Version: 1.0
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
 <20190529162532.GG18589@dhcp22.suse.cz> <CAFbcbMDJB0uNjTa9xwT9npmTdqMJ1Hez3CyeOCjjrLF2W0Wprw@mail.gmail.com>
 <20190529174931.GH18589@dhcp22.suse.cz> <CAFbcbMA6XjZqrgHmG70Vm_a34Rn4tKqoMgQkRBXES2r3+ymYwg@mail.gmail.com>
 <20190530062418.GB6703@dhcp22.suse.cz>
In-Reply-To: <20190530062418.GB6703@dhcp22.suse.cz>
From: Dianzhang Chen <dianzhangchen0@gmail.com>
Date: Thu, 30 May 2019 15:01:26 +0800
Message-ID: <CAFbcbMA4UKErsTDp97QgYkqBXLiL_YbfSE4JM80NVDqpHQgTkQ@mail.gmail.com>
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in kmalloc_slab()
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, 
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 2:24 PM Michal Hocko <mhocko@kernel.org> wrote:
> I understand the general mechanism of spectre v1. What I was asking for
> is an example of where userspace directly controls the allocation size
> as this is usually bounded to an in kernel object size. I can see how
> and N * sizeof(object) where N is controlled by the userspace could be
> the target. But calling that out explicitly would be appreciated.

In the syscall call poll, the user can control the `nfds`,
when call the function `do_sys_poll` it can pass the nfds to function
`do_sys_poll`, and pass to variable `len`,
although there exit compare instruction llike `len = min_t(unsigned
int, nfds, N_STACK_PPS)`, `len = min(todo, POLLFD_PER_PAGE);`,
but it can also bypass by speculation, as the speculation windows are large,
and in the next `size = sizeof(struct poll_list) + sizeof(struct pollfd) * len`,
which can indirect control the size.


> Please mention that in the changelog as well.
ok, thanks for suggestion.

