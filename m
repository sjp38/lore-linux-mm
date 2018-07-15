Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1A26B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 21:08:58 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id n3-v6so3126005ljc.17
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 18:08:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b22-v6sor5745944lji.6.2018.07.14.18.08.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 18:08:56 -0700 (PDT)
MIME-Version: 1.0
References: <1531482952-4595-1-git-send-email-ufo19890607@gmail.com> <alpine.DEB.2.21.1807131521030.202408@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1807131521030.202408@chino.kir.corp.google.com>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Sun, 15 Jul 2018 09:08:05 +0800
Message-ID: <CAHCio2je-k-vTejPO=hv2DDHD6XQ5Q4JeKDkMoDscoyjiZAeFw@mail.gmail.com>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context information
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi David
Could I use use plain old %d? Just like this,
pr_cont(",task=%s,pid=%d,uid=%d\n", p->comm, p->pid,
from_kuid(&init_user_ns, task_uid(p)));

Thanks
