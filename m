Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2C0B6B0009
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:13:47 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id f18-v6so225465ybn.13
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 08:13:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 203-v6sor100886ybf.71.2018.03.19.08.13.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 08:13:46 -0700 (PDT)
Date: Mon, 19 Mar 2018 08:13:43 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
Message-ID: <20180319151343.GK2943022@devbig577.frc2.facebook.com>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180314220909.GE2943022@devbig577.frc2.facebook.com>
 <20180314152203.c06fce436d221d34d3e4cf4a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314152203.c06fce436d221d34d3e4cf4a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Andrew.

On Wed, Mar 14, 2018 at 03:22:03PM -0700, Andrew Morton wrote:
> hm.  spose so.  Maybe.  Are there other ways?  I assume the time is
> being spent in pcpu_create_chunk()?  We could drop the mutex while
> running that stuff and take the appropriate did-we-race-with-someone
> testing after retaking it.  Or similar.

I'm not sure that'd change much.  Ultimately, isn't the choice between
being able to return NULL and waiting for more memory?  If we decide
to return NULL, it doesn't make difference where we do that from,
right?

Thanks.

-- 
tejun
