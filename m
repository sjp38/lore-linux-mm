Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id A54756B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 11:58:27 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id s12-v6so12720966ywl.13
        for <linux-mm@kvack.org>; Wed, 30 May 2018 08:58:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g78-v6sor2207557yba.52.2018.05.30.08.58.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 08:58:26 -0700 (PDT)
Date: Wed, 30 May 2018 08:58:24 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 04/13] blk: introduce REQ_SWAP
Message-ID: <20180530155824.GL1351649@devbig577.frc2.facebook.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-5-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-5-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, May 29, 2018 at 05:17:15PM -0400, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Just like REQ_META, it's important to know the IO coming down is swap
> in order to guard against potential IO priority inversion issues with
> cgroups.  Add REQ_SWAP and use it for all swap IO, and add it to our
> bio_issue_as_root_blkg helper.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
