Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCA76B0027
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 10:52:23 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w10so12064993wrg.15
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 07:52:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c23si1213166wrc.256.2018.03.27.07.52.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 07:52:22 -0700 (PDT)
Date: Tue, 27 Mar 2018 16:52:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Introduce i_mmap_lock_write_killable().
Message-ID: <20180327145220.GJ5652@dhcp22.suse.cz>
References: <1522149570-4517-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522149570-4517-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>

On Tue 27-03-18 20:19:30, Tetsuo Handa wrote:
> If the OOM victim is holding mm->mmap_sem held for write, and if the OOM
> victim can interrupt operations which need mm->mmap_sem held for write,
> we can downgrade mm->mmap_sem upon SIGKILL and the OOM reaper will be
> able to reap the OOM victim's memory.

This really begs for much better explanation. Why is it safe? Are you
assuming that the killed task will not perform any changes on the
address space? What about ongoing page faults or other operations deeper
in the call chain. Why they are safe to change things for the child
during the copy?

I am not saying this is wrong, I would have to think about that much
more because mmap_sem tends to be used on many surprising places and the
write lock just hide them all.
-- 
Michal Hocko
SUSE Labs
