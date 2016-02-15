Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5C41E6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 15:50:33 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so124831788wme.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:50:33 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id t8si27904720wmd.71.2016.02.15.12.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 12:50:32 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id a4so12401218wme.3
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:50:32 -0800 (PST)
Date: Mon, 15 Feb 2016 21:50:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/5] mm, oom: introduce oom reaper
Message-ID: <20160215205028.GE9223@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-2-git-send-email-mhocko@kernel.org>
 <201602062222.HJH86328.SMFVtFOJFHQOLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602062222.HJH86328.SMFVtFOJFHQOLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-02-16 22:22:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > There is one notable exception to this, though, if the OOM victim was
> > in the process of coredumping the result would be incomplete. This is
> > considered a reasonable constrain because the overall system health is
> > more important than debugability of a particular application.
> 
> Is it possible to clarify what "the result would be incomplete" mean?
> 
>   (1) The size of coredump file becomes smaller than it should be, and
>       data in reaped pages is not included into the file.
> 
>   (2) The size of coredump file does not change, and data in reaped pages
>       is included into the file as NUL byte.

AFAIU this will be the case. We are not destroying VMAs we are just
unmapping the page ranges. So what would happen is that the core dump
will contain zero pages for anonymous mappings. This might change in
future though because the oom repear might be extended to do more work
(e.g. drop associated page tables when I would expect the core dumping
could SEGV).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
