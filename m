Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62C2B6B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 01:56:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 31-v6so358879edr.19
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 22:56:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k31-v6si378396ede.264.2018.10.22.22.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 22:56:58 -0700 (PDT)
Date: Tue, 23 Oct 2018 07:56:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Use timeout based back off.
Message-ID: <20181023055655.GM18839@dhcp22.suse.cz>
References: <1540033021-3258-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1810221406400.120157@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810221406400.120157@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Mon 22-10-18 14:11:10, David Rientjes wrote:
[...]
> I've proposed patches that have been running for months in a production 
> environment that make the oom killer useful without serially killing many 
> processes unnecessarily.  At this point, it is *much* easier to just fork 
> the oom killer logic rather than continue to invest time into fixing it in 
> Linux.  That's unfortunate because I'm sure you realize how problematic 
> the current implementation is, how abusive it is, and have seen its 
> effects yourself.  I admire your persistance in trying to fix the issues 
> surrounding the oom killer, but have come to the conclusion that forking 
> it is a much better use of time.

These are some pretty strong words for a code that tends to work for
most users out there. I do not remember any bug reports except for
artificial stress tests or your quite unspecific claims about absolutely
catastrophic impact which is not backed by any specific details.

I have shown interest in addressing as many issues as possible but I
absolutely detest getting back to the previous state with an
indeterministic pile of heuristic which were lockup prone and basically
unmaintainable.

Going around with timeouts and potentially export them to userspace
might sound attractive for the simplicity but this should be absolutely
the last resort when a proper solution is too complex (from a code or
maintainability POV). I do not believe we have reached that state yet.
-- 
Michal Hocko
SUSE Labs
