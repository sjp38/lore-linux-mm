Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35AFB6B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 16:50:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h11so1581836pfn.0
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:50:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z127sor720655pgb.321.2018.03.20.13.50.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 13:50:01 -0700 (PDT)
Date: Tue, 20 Mar 2018 13:49:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm,oom_reaper: Check for MMF_OOM_SKIP before
 complain.
In-Reply-To: <201803202147.ICB09393.FFSJOOtHVQOFLM@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1803201349270.167205@chino.kir.corp.google.com>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <1521547076-3399-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20180320121246.GK23100@dhcp22.suse.cz> <201803202137.CAC35494.OFtJLHFSFOMVOQ@I-love.SAKURA.ne.jp>
 <201803202147.ICB09393.FFSJOOtHVQOFLM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.com, linux-mm@kvack.org

On Tue, 20 Mar 2018, Tetsuo Handa wrote:

> I got "oom_reaper: unable to reap pid:" messages when the victim thread
> was blocked inside free_pgtables() (which occurred after returning from
> unmap_vmas() and setting MMF_OOM_SKIP). We don't need to complain when
> exit_mmap() already set MMF_OOM_SKIP.
> 
> [  663.593821] Killed process 7558 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  664.684801] oom_reaper: unable to reap pid:7558 (a.out)
> [  664.892292] a.out           D13272  7558   6931 0x00100084
> [  664.895765] Call Trace:
> [  664.897574]  ? __schedule+0x25f/0x780
> [  664.900099]  schedule+0x2d/0x80
> [  664.902260]  rwsem_down_write_failed+0x2bb/0x440
> [  664.905249]  ? rwsem_down_write_failed+0x55/0x440
> [  664.908335]  ? free_pgd_range+0x569/0x5e0
> [  664.911145]  call_rwsem_down_write_failed+0x13/0x20
> [  664.914121]  down_write+0x49/0x60
> [  664.916519]  ? unlink_file_vma+0x28/0x50
> [  664.919255]  unlink_file_vma+0x28/0x50
> [  664.922234]  free_pgtables+0x36/0x100
> [  664.924797]  exit_mmap+0xbb/0x180
> [  664.927220]  mmput+0x50/0x110
> [  664.929504]  copy_process.part.41+0xb61/0x1fe0
> [  664.932448]  ? _do_fork+0xe6/0x560
> [  664.934902]  ? _do_fork+0xe6/0x560
> [  664.937361]  _do_fork+0xe6/0x560
> [  664.939742]  ? syscall_trace_enter+0x1a9/0x240
> [  664.942693]  ? retint_user+0x18/0x18
> [  664.945309]  ? page_fault+0x2f/0x50
> [  664.947896]  ? trace_hardirqs_on_caller+0x11f/0x1b0
> [  664.951075]  do_syscall_64+0x74/0x230
> [  664.953747]  entry_SYSCALL_64_after_hwframe+0x42/0xb7
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

But you'll need to send it to akpm.
