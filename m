Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 095E66B000C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:14:51 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id u6so5029314ywc.4
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 08:14:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h30-v6sor94030ybi.32.2018.03.19.08.14.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 08:14:50 -0700 (PDT)
Date: Mon, 19 Mar 2018 08:14:47 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
Message-ID: <20180319151447.GL2943022@devbig577.frc2.facebook.com>
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

On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
> > +	if (!is_atomic) {
> > +		if (gfp & __GFP_NOFAIL)
> > +			mutex_lock(&pcpu_alloc_mutex);
> > +		else if (mutex_lock_killable(&pcpu_alloc_mutex))
> > +			return NULL;
> > +	}
> 
> It would benefit from a comment explaining why we're doing this (it's
> for the oom-killer).

And, yeah, this would be great.  Kirill, can you please send a patch
to add a comment there?

Thanks.

-- 
tejun
