Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E37B680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:37:21 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y2so55951949qkb.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:37:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d15si904748qta.154.2017.02.14.09.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 09:37:21 -0800 (PST)
Date: Tue, 14 Feb 2017 18:37:17 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom_reaper: switch to struct list_head for reap queue
Message-ID: <20170214173717.GA8913@redhat.com>
References: <20170214150714.6195-1-asarai@suse.de>
 <20170214163005.GA2450@cmpxchg.org>
 <e876e49b-8b65-d827-af7d-cbf8aef97585@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e876e49b-8b65-d827-af7d-cbf8aef97585@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aleksa Sarai <asarai@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyphar@cyphar.com

On 02/15, Aleksa Sarai wrote:
>
> >This is an extra pointer to task_struct and more lines of code to
> >accomplish the same thing. Why would we want to do that?
>
> I don't think it's more "actual" lines of code (I think the wrapping is
> inflating the line number count),

I too think it doesn't make sense to blow task_struct and the generated code.
And to me this patch doesn't make the source code more clean.

> but switching it means that it's more in
> line with other queues in the kernel (it took me a bit to figure out what
> was going on with oom_reaper_list beforehand).

perhaps you can turn oom_reaper_list into llist_head then. This will also
allow to remove oom_reaper_lock. Not sure this makes sense too.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
