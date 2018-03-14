Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 188896B0010
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 09:55:48 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id b7so3780754ywe.17
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 06:55:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h189sor1044373ywf.181.2018.03.14.06.55.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 06:55:47 -0700 (PDT)
Date: Wed, 14 Mar 2018 06:55:44 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
Message-ID: <20180314135544.GT2943022@devbig577.frc2.facebook.com>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 14, 2018 at 02:51:48PM +0300, Kirill Tkhai wrote:
> In case of memory deficit and low percpu memory pages,
> pcpu_balance_workfn() takes pcpu_alloc_mutex for a long
> time (as it makes memory allocations itself and waits
> for memory reclaim). If tasks doing pcpu_alloc() are
> choosen by OOM killer, they can't exit, because they
> are waiting for the mutex.
> 
> The patch makes pcpu_alloc() to care about killing signal
> and use mutex_lock_killable(), when it's allowed by GFP
> flags. This guarantees, a task does not miss SIGKILL
> from OOM killer.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Applied to percpu/for-4.16-fixes.

Thanks, Kirill.

-- 
tejun
