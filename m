Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0F06B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:09:02 -0500 (EST)
Received: by wmuu63 with SMTP id u63so137273707wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:09:02 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id b83si5730062wme.104.2015.11.25.05.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 05:09:01 -0800 (PST)
Received: by wmvv187 with SMTP id v187so256258721wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:09:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <565592A1.50407@I-love.SAKURA.ne.jp>
References: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
 <20151125084403.GA24703@dhcp22.suse.cz> <565592A1.50407@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 25 Nov 2015 14:08:41 +0100
Message-ID: <CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
Subject: Re: WARNING in handle_mm_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Wed, Nov 25, 2015 at 11:51 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> On 2015/11/25 17:44, Michal Hocko wrote:
>> Sasha has reported the same thing some time ago
>> http://www.spinics.net/lists/cgroups/msg14075.html. Tejun had a theory
>> http://www.spinics.net/lists/cgroups/msg14078.html but we never got down
>> to the solution.
>
> Did you check assembly code?
> https://gcc.gnu.org/ml/gcc/2012-02/msg00005.html

If the race described in
http://www.spinics.net/lists/cgroups/msg14078.html does actually
happen, then there is nothing to check.
https://gcc.gnu.org/ml/gcc/2012-02/msg00005.html talks about different
memory locations, if there is store-widening involving different
memory locations, then this is a compiler bug. But the race happens on
a single memory location, in such case the code is buggy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
