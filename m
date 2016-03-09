Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C35686B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 09:55:56 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so74525553wmp.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 06:55:56 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id 187si5024296wmg.2.2016.03.09.06.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 06:55:32 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id l68so74578974wml.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 06:55:32 -0800 (PST)
Date: Wed, 9 Mar 2016 15:55:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Reduce needless dereference.
Message-ID: <20160309145512.GA27011@dhcp22.suse.cz>
References: <1457434951-12691-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160308183032.GA9571@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160308183032.GA9571@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org

On Tue 08-03-16 13:30:32, Johannes Weiner wrote:
> On Tue, Mar 08, 2016 at 08:02:31PM +0900, Tetsuo Handa wrote:
> > Since we assigned mm = victim->mm before pr_err(),
> > we don't need to dereference victim->mm again at pr_err().
> > This saves a few instructions.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Yes. Once we introduce a local variable for something, we should use
> it consistently to refer to that thing. Anything else is confusing.

The victim->mm association is stable here because of the task_lock but I
agree that this might be not obvious and reusing the local variable is
easier to read and understand. I doubt we care about the change in the
generated code as an argument though. So just for the sake of clean up

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
