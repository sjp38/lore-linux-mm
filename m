Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id E9B666B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:59:37 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l68so13329530wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:59:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w81si2032480wma.101.2016.03.11.02.59.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 02:59:36 -0800 (PST)
Subject: Re: [PATCH] mm, proc: make clear_refs killable
References: <1456752417-9626-8-git-send-email-mhocko@kernel.org>
 <1456768587-24893-1-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E2A517.9040703@suse.cz>
Date: Fri, 11 Mar 2016 11:59:35 +0100
MIME-Version: 1.0
In-Reply-To: <1456768587-24893-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Petr Cermak <petrcermak@chromium.org>

On 02/29/2016 06:56 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> CLEAR_REFS_MM_HIWATER_RSS and CLEAR_REFS_SOFT_DIRTY are relying on
> mmap_sem for write. If the waiting task gets killed by the oom killer
> and it would operate on the current's mm it would block oom_reaper from
> asynchronous address space reclaim and reduce the chances of timely OOM
> resolving. Wait for the lock in the killable mode and return with EINTR
> if the task got killed while waiting. This will also expedite the return
> to the userspace and do_exit even if the mm is remote.
>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Petr Cermak <petrcermak@chromium.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
