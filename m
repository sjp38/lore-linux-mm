Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5DAB6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 12:31:22 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id n65-v6so12118090ybn.10
        for <linux-mm@kvack.org>; Wed, 30 May 2018 09:31:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p129-v6sor8411700ywf.483.2018.05.30.09.31.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 09:31:21 -0700 (PDT)
Date: Wed, 30 May 2018 09:31:18 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 08/13] blk-stat: export helpers for modifying blk_rq_stat
Message-ID: <20180530163118.GO1351649@devbig577.frc2.facebook.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-9-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-9-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, May 29, 2018 at 05:17:19PM -0400, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> We need to use blk_rq_stat in the blkcg qos stuff, so export some of
> these helpers so they can be used by other things.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
