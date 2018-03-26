Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44F6B6B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 09:21:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i19so2224264wmf.1
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 06:21:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l22si9800050wmh.16.2018.03.26.06.20.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 06:20:59 -0700 (PDT)
Date: Mon, 26 Mar 2018 15:20:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] lockdep: Show address of "struct lockdep_map" at
 print_lock().
Message-ID: <20180326132057.GJ5652@dhcp22.suse.cz>
References: <1522059513-5461-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180326131911.GI5652@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180326131911.GI5652@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: peterz@infradead.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Borislav Petkov <bp@suse.de>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon 26-03-18 15:19:11, Michal Hocko wrote:
> On Mon 26-03-18 19:18:33, Tetsuo Handa wrote:
> > Currently, print_lock() is printing hlock->acquire_ip field in both
> > "[<%px>]" and "%pS" format. But "[<%px>]" is little useful nowadays, for
> > we use scripts/faddr2line which receives "%pS" for finding the location
> > in the source code.
> > 
> > Since "struct lockdep_map" is embedded into lock objects, we can know
> > which instance of a lock object is acquired using hlock->instance field.
> > This will help finding which threads are causing a lock contention when
> > e.g. the OOM reaper failed to acquire an OOM victim's mmap_sem for read.
> 
> How? All I can see is that we can match which instances are the same.
> This would be an interesting thing to know AFAICS because you can tell
> different instances of lock apart. So the patch makes some sense to me,
> I am just not sure about changelog.

Also, are you sure that %px is appropriate? Can this be abused to leak
the kernel pointer and infere other useful data from it? %p should be
sufficient to tell different lock instances even with the hashed
addresses.
-- 
Michal Hocko
SUSE Labs
