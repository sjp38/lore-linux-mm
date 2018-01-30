Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0EA6B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 09:04:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 137so1880536wml.0
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 06:04:21 -0800 (PST)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id s10si12950718wrs.372.2018.01.30.06.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 06:04:20 -0800 (PST)
Date: Tue, 30 Jan 2018 15:01:11 +0100
From: Florian Westphal <fw@strlen.de>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180130140111.GM5906@breakpoint.cc>
References: <20180129082649.sysf57wlp7i7ltb2@node.shutemov.name>
 <20180129165722.GF5906@breakpoint.cc>
 <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc>
 <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc>
 <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
 <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
 <20180130095739.GV21609@dhcp22.suse.cz>
 <20180130140104.GE21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130140104.GE21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Florian Westphal <fw@strlen.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

> From d48e950f1b04f234b57b9e34c363bdcfec10aeee Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 30 Jan 2018 14:51:07 +0100
> Subject: [PATCH] net/netfilter/x_tables.c: make allocation less aggressive

Acked-by: Florian Westphal <fw@strlen.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
