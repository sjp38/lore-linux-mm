Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 076668E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:50:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d47-v6so519434edb.3
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 00:50:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k15-v6si600302edb.253.2018.09.12.00.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 00:50:57 -0700 (PDT)
Date: Wed, 12 Sep 2018 09:50:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180912075054.GZ10951@dhcp22.suse.cz>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 11-09-18 23:01:57, Tetsuo Handa wrote:
> On 2018/09/10 21:55, Michal Hocko wrote:
> > This is a very coarse implementation of the idea I've had before.
> > Please note that I haven't tested it yet. It is mostly to show the
> > direction I would wish to go for.
> 
> Hmm, this patchset does not allow me to boot. ;-)
> 
>         free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
>                         FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> 
> [    1.875675] sched_clock: Marking stable (1810466565, 65169393)->(1977240380, -101604422)
> [    1.877833] registered taskstats version 1
> [    1.877853] Loading compiled-in X.509 certificates
> [    1.878835] zswap: loaded using pool lzo/zbud
> [    1.880835] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008

This is vm_prev == NULL. I thought we always have vm_prev as long as
this is not a single VMA in the address space. I will double check this.
-- 
Michal Hocko
SUSE Labs
