Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 831C46B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 09:40:03 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d63so393856wma.4
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 06:40:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d11si12789728wrg.144.2018.01.30.06.40.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 06:40:02 -0800 (PST)
Date: Tue, 30 Jan 2018 15:39:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180130143958.GG21609@dhcp22.suse.cz>
References: <20180129165722.GF5906@breakpoint.cc>
 <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc>
 <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc>
 <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
 <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
 <20180130095739.GV21609@dhcp22.suse.cz>
 <20180130140104.GE21609@dhcp22.suse.cz>
 <20180130140111.GM5906@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130140111.GM5906@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>
Cc: Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 30-01-18 15:01:11, Florian Westphal wrote:
> > From d48e950f1b04f234b57b9e34c363bdcfec10aeee Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 30 Jan 2018 14:51:07 +0100
> > Subject: [PATCH] net/netfilter/x_tables.c: make allocation less aggressive
> 
> Acked-by: Florian Westphal <fw@strlen.de>

Thanks! How should we route this change? Andrew, David?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
