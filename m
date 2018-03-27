Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D83676B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:50:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p4so8236970wrf.17
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 03:50:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m27si839236wrb.90.2018.03.27.03.50.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 03:50:49 -0700 (PDT)
Date: Tue, 27 Mar 2018 12:50:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] lockdep: Show address of "struct lockdep_map" at
 print_lock().
Message-ID: <20180327105048.GE5652@dhcp22.suse.cz>
References: <1522059513-5461-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180326160549.GL4043@hirez.programming.kicks-ass.net>
 <201803270558.HCA41032.tVFJOFOMOFLHSQ@I-love.SAKURA.ne.jp>
 <201803271941.GBE57310.tVSOJLQOFFOHFM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803271941.GBE57310.tVSOJLQOFFOHFM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: peterz@infradead.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, rientjes@google.com, tglx@linutronix.de

On Tue 27-03-18 19:41:41, Tetsuo Handa wrote:
> >From 91c081c4c5f6a99402542951e7de661c38f928ab Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 27 Mar 2018 19:38:33 +0900
> Subject: [PATCH v2] lockdep: Show address of "struct lockdep_map" at print_lock().
> 
> Since "struct lockdep_map" is embedded into lock objects, we can know
> which instance of a lock object is acquired using hlock->instance field.
> This will help finding which threads are causing a lock contention.
> 
> Currently, print_lock() is printing hlock->acquire_ip field in both
> "[<%px>]" and "%pS" format. But "[<%px>]" is little useful nowadays, for
> we use scripts/faddr2line which receives "%pS" for finding the location
> in the source code. And I want to reduce amount of output, for
> debug_show_all_locks() might print a lot.
> 
> Therefore, this patch replaces "[<%px>]" for printing hlock->acquire_ip
> field with "%p" for printing hlock->instance field.
> 
> [  251.305475] 3 locks held by a.out/31106:
> [  251.308949]  #0: 00000000b0f753ba (&mm->mmap_sem){++++}, at: copy_process.part.41+0x10d5/0x1fe0
> [  251.314283]  #1: 00000000ef64d539 (&mm->mmap_sem/1){+.+.}, at: copy_process.part.41+0x10fe/0x1fe0
> [  251.319618]  #2: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: copy_process.part.41+0x12f2/0x1fe0
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Michal Hocko <mhocko@suse.com>

Looks good to me. Feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
