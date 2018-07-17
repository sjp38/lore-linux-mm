Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 624776B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 23:51:17 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f31-v6so18134807plb.10
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:51:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 134-v6sor9098659pfw.95.2018.07.16.20.51.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 20:51:16 -0700 (PDT)
Date: Mon, 16 Jul 2018 20:51:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context
 information
In-Reply-To: <CAHCio2je-k-vTejPO=hv2DDHD6XQ5Q4JeKDkMoDscoyjiZAeFw@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1807162051080.157949@chino.kir.corp.google.com>
References: <1531482952-4595-1-git-send-email-ufo19890607@gmail.com> <alpine.DEB.2.21.1807131521030.202408@chino.kir.corp.google.com> <CAHCio2je-k-vTejPO=hv2DDHD6XQ5Q4JeKDkMoDscoyjiZAeFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="1113858990-1551172007-1531799474=:157949"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1113858990-1551172007-1531799474=:157949
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sun, 15 Jul 2018, c|1e??e?(R) wrote:

> Hi David
> Could I use use plain old %d? Just like this,
> pr_cont(",task=%s,pid=%d,uid=%d\n", p->comm, p->pid,
> from_kuid(&init_user_ns, task_uid(p)));
> 

Yes please!
--1113858990-1551172007-1531799474=:157949--
