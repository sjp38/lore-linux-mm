Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BD6054402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:37:34 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so63444262pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:37:34 -0800 (PST)
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com. [209.85.220.54])
        by mx.google.com with ESMTPS id t67si35542316pfi.114.2015.11.25.09.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 09:37:34 -0800 (PST)
Received: by padhx2 with SMTP id hx2so63563467pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:37:34 -0800 (PST)
Date: Wed, 25 Nov 2015 18:37:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in handle_mm_fault
Message-ID: <20151125173730.GS27283@dhcp22.suse.cz>
References: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
 <20151125084403.GA24703@dhcp22.suse.cz>
 <565592A1.50407@I-love.SAKURA.ne.jp>
 <CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
 <201511260027.CCC26590.SOHFMQLVJOtFOF@I-love.SAKURA.ne.jp>
 <CACT4Y+ZdF09hOnb_bL4GNjytSMMGvNde8=9pdZt6gZQB1sp0hQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZdF09hOnb_bL4GNjytSMMGvNde8=9pdZt6gZQB1sp0hQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Wed 25-11-15 18:21:02, Dmitry Vyukov wrote:
[...]
> I have some progress.

Please have a look at Peter's patch posted in the original email thread
http://lkml.kernel.org/r/20151125150207.GM11639@twins.programming.kicks-ass.net
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
