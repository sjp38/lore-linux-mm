Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3B836B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 03:12:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 11so3303379pge.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 00:12:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si242977plz.80.2017.09.15.00.12.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 00:12:32 -0700 (PDT)
Date: Fri, 15 Sep 2017 09:12:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + include-linux-sched-mmh-uninline-mmdrop_async-etc.patch added
 to -mm tree
Message-ID: <20170915071228.bw5f2atahrfhj7zp@dhcp22.suse.cz>
References: <59bae45a.Fmr8uSXzjRP94/2V%akpm@linux-foundation.org>
 <20170915070731.y5ddmgtzvjz5aot3@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915070731.y5ddmgtzvjz5aot3@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mingo@kernel.org, oleg@redhat.com, peterz@infradead.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri 15-09-17 09:07:31, Michal Hocko wrote:
> On Thu 14-09-17 13:19:38, Andrew Morton wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: include/linux/sched/mm.h: uninline mmdrop_async(), etc
> > 
> > mmdrop_async() is only used in fork.c.  Move that and its support
> > functions into fork.c, uninline it all.
> 
> Is this really an improvement? Why do we want to discourage more code
> paths to use mmdrop_async? It sounds like a useful api and it has been
> removed only because it lost its own user in oom code. Now that we have
> a user I would just keep it where it was before.

Dohh, I have mixed mmput_async with mmdrop_async. Anyway I still think
that this is universal enough to have it in a header rather than hiding
it in fork.c
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
