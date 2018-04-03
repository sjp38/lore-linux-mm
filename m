Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85BE96B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 09:06:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e185so7431718wmg.5
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 06:06:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si2111682wmy.271.2018.04.03.06.06.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 06:06:30 -0700 (PDT)
Date: Tue, 3 Apr 2018 15:06:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-ID: <20180403130628.GZ5501@dhcp22.suse.cz>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
 <201803301934.DHF12420.SOFFJQMLVtHOOF@I-love.SAKURA.ne.jp>
 <20180403121414.GD5832@bombadil.infradead.org>
 <20180403121950.GW5501@dhcp22.suse.cz>
 <201804032129.HIH05759.FJOFOQLtVHMFSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201804032129.HIH05759.FJOFOQLtVHMFSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: willy@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, riel@redhat.com

On Tue 03-04-18 21:29:52, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Please be aware that we _do_ allocate in the exit path. I have a strong
> > suspicion that even while fatal signal is pending. Do we really want
> > fail those really easily.
> 
> Does the exit path mean inside do_exit() ? If yes, fatal signals are already
> cleared before reaching do_exit().

They usually are. But we can send a SIGKILL on an already killed task
after it removed the previously deadly signal already AFAIR. Maybe I
mis-remember of course. Signal handling code always makes my head
explode and I tend to forget all the details. Anyway relying on
fatal_signal_pending for some allocator semantic is just too subtle.
-- 
Michal Hocko
SUSE Labs
