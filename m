Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 769486B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 12:39:44 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id n8so16622632ywh.10
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 09:39:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d62-v6sor164071ybc.164.2018.03.19.09.39.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 09:39:43 -0700 (PDT)
Date: Mon, 19 Mar 2018 09:39:40 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] mm: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
Message-ID: <20180319163940.GA519464@devbig577.frc2.facebook.com>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180319151447.GL2943022@devbig577.frc2.facebook.com>
 <4e8ca27a-9c92-8f1e-fb72-88758a266cb6@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e8ca27a-9c92-8f1e-fb72-88758a266cb6@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 19, 2018 at 06:32:10PM +0300, Kirill Tkhai wrote:
> From: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
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

Thanks.

-- 
tejun
