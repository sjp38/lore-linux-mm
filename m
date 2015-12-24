Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6301A82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 15:39:52 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id o11so102808746qge.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 12:39:52 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id s5si11741074qki.65.2015.12.24.12.39.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 12:39:51 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id t125so17158187qkh.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 12:39:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201512242006.CGJ81784.SVMHOOQtLFFFOJ@I-love.SAKURA.ne.jp>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
	<CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
	<20151224094758.GA22760@dhcp22.suse.cz>
	<201512242006.CGJ81784.SVMHOOQtLFFFOJ@I-love.SAKURA.ne.jp>
Date: Thu, 24 Dec 2015 13:39:51 -0700
Message-ID: <CAOxpaSXxFHSmj6iaTqHTJ0pT_9F4tYnCXFbgnsF9jxeJS1adCw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Ross Zwisler <zwisler@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Dec 24, 2015 at 4:06 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Michal Hocko wrote:
>> This is VM_BUG_ON_PAGE(page_mapped(page), page), right? Could you attach
>> the full kernel log? It all smells like a race when OOM reaper tears
>> down the mapping and there is a truncate still in progress. But hitting
>> the BUG_ON just because of that doesn't make much sense to me. OOM
>> reaper is essentially MADV_DONTNEED. I have to think about this some
>> more, though, but I am in a holiday mode until early next year so please
>> bear with me.
>
> I don't know whether the OOM killer was invoked just before this
> VM_BUG_ON_PAGE().
>
>> Is this somehow DAX related?
>
> 4.4.0-rc6-next-20151223_new_fsync_v6+ suggests that this kernel
> has "[PATCH v6 0/7] DAX fsync/msync support" applied. But I think
> http://marc.info/?l=linux-mm&m=145068666428057 should be applied
> when retesting. (20151223 does not have this fix.)

No, DAX was not turned on, and while my fsync/msync patches were the initial
reason I was testing (hence the new_fsync_v6 kernel name) they were not
applied during the bisect, so I'm sure they are not related to this issue.

I will retest with the patch referenced above, but it probably won't
happen until
the new year.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
