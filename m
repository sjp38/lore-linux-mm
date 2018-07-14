Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD85B6B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 11:38:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4-v6so7746392wme.7
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 08:38:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13-v6sor12332194wrh.60.2018.07.14.08.38.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 08:38:31 -0700 (PDT)
MIME-Version: 1.0
References: <1531557122-12540-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1531557122-12540-1-git-send-email-laoar.shao@gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 14 Jul 2018 08:38:17 -0700
Message-ID: <CALvZod57QFRVQ7kM4LSNQJACQ+dGC_otJkqK-5+i-0b53Zq5aA@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid bothering interrupted task when charge memcg in softirq
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jul 14, 2018 at 1:32 AM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> try_charge maybe executed in packet receive path, which is in interrupt
> context.
> In this situation, the 'current' is the interrupted task, which may has
> no relation to the rx softirq, So it is nonsense to use 'current'.
>

Have you actually seen this occurring? I am not very familiar with the
network code but I can think of two ways try_charge() can be called
from network code. Either through kmem charging or through
mem_cgroup_charge_skmem() and both locations correctly handle
interrupt context.

Shakeel
