Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 51D2E6B0093
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 11:16:45 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so1682851pab.18
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 08:16:45 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.229])
        by mx.google.com with ESMTP id fl2si40022871pbb.202.2014.09.18.08.16.43
        for <linux-mm@kvack.org>;
        Thu, 18 Sep 2014 08:16:43 -0700 (PDT)
Date: Thu, 18 Sep 2014 11:16:34 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] cgroup/kmemleak: add kmemleak_free() for cgroup
 deallocations.
Message-ID: <20140918111634.1bb56716@gandalf.local.home>
In-Reply-To: <20140918141639.GA17230@cmpxchg.org>
References: <1411004285-42101-1-git-send-email-wangnan0@huawei.com>
	<20140918141639.GA17230@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Wang Nan <wangnan0@huawei.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>

On Thu, 18 Sep 2014 10:16:39 -0400
Johannes Weiner <hannes@cmpxchg.org> wrote:
 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Should this go into -stable?  I'm inclined to say no, this has been
> busted since Steve's other kmemleak fix since 2011, and that change
> also didn't go into -stable.

It only breaks kmem tests, and since nobody noticed recently, I don't
think it needs to go into stable.

On the other hand, it's a very non intrusive fix that I highly doubt
will cause other regressions, so it may not be bad to add a stable tag
to it.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
