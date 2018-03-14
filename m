Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF7B6B0009
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 18:09:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e6so3086171qkf.19
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 15:09:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u90sor2425564qku.144.2018.03.14.15.09.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 15:09:12 -0700 (PDT)
Date: Wed, 14 Mar 2018 15:09:09 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
Message-ID: <20180314220909.GE2943022@devbig577.frc2.facebook.com>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Andrew.

On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
> It would benefit from a comment explaining why we're doing this (it's
> for the oom-killer).

Will add.

> My memory is weak and our documentation is awful.  What does
> mutex_lock_killable() actually do and how does it differ from
> mutex_lock_interruptible()?  Userspace tasks can run pcpu_alloc() and I

IIRC, killable listens only to SIGKILL.

> wonder if there's any way in which a userspace-delivered signal can
> disrupt another userspace task's memory allocation attempt?

Hmm... maybe.  Just honoring SIGKILL *should* be fine but the alloc
failure paths might be broken, so there are some risks.  Given that
the cases where userspace tasks end up allocation percpu memory is
pretty limited and/or priviledged (like mount, bpf), I don't think the
risks are high tho.

Thanks.

-- 
tejun
