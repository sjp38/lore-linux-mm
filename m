Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 972E56B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:52:04 -0500 (EST)
Received: by padhx2 with SMTP id hx2so54263945pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:52:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e25si33597480pfd.29.2015.11.25.02.52.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 02:52:04 -0800 (PST)
Subject: Re: WARNING in handle_mm_fault
References: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
 <20151125084403.GA24703@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <565592A1.50407@I-love.SAKURA.ne.jp>
Date: Wed, 25 Nov 2015 19:51:13 +0900
MIME-Version: 1.0
In-Reply-To: <20151125084403.GA24703@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On 2015/11/25 17:44, Michal Hocko wrote:
> Sasha has reported the same thing some time ago
> http://www.spinics.net/lists/cgroups/msg14075.html. Tejun had a theory
> http://www.spinics.net/lists/cgroups/msg14078.html but we never got down
> to the solution.

Did you check assembly code?
https://gcc.gnu.org/ml/gcc/2012-02/msg00005.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
