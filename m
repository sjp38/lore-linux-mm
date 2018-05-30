Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id B69D46B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 11:53:22 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id 189-v6so12289595ybf.3
        for <linux-mm@kvack.org>; Wed, 30 May 2018 08:53:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15-v6sor8301991ybp.168.2018.05.30.08.53.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 08:53:22 -0700 (PDT)
Date: Wed, 30 May 2018 08:53:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 02/13] block: introduce bio_issue_as_root_blkg
Message-ID: <20180530155319.GJ1351649@devbig577.frc2.facebook.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-3-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-3-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, May 29, 2018 at 05:17:13PM -0400, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Instead of forcing all file systems to get the right context on their
> bio's, simply check for REQ_META to see if we need to issue as the root
> blkg.  We don't want to force all bio's to have the root blkg associated
> with them if REQ_META is set, as some controllers (blk-iolatency) need
> to know who the originating cgroup is so it can backcharge them for the
> work they are doing.  This helper will make sure that the controllers do
> the proper thing wrt the IO priority and backcharging.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
