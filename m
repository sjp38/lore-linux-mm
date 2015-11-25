Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6484402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:44:22 -0500 (EST)
Received: by wmww144 with SMTP id w144so189941705wmw.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:44:21 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id v126si7249071wmb.23.2015.11.25.09.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 09:44:21 -0800 (PST)
Received: by wmuu63 with SMTP id u63so147799386wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:44:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151125173730.GS27283@dhcp22.suse.cz>
References: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
 <20151125084403.GA24703@dhcp22.suse.cz> <565592A1.50407@I-love.SAKURA.ne.jp>
 <CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
 <201511260027.CCC26590.SOHFMQLVJOtFOF@I-love.SAKURA.ne.jp>
 <CACT4Y+ZdF09hOnb_bL4GNjytSMMGvNde8=9pdZt6gZQB1sp0hQ@mail.gmail.com> <20151125173730.GS27283@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 25 Nov 2015 18:44:00 +0100
Message-ID: <CACT4Y+Y0EESD_HhgGE2pWPqfJsDgvSny=ZMfP1ewaSzd6z_bLg@mail.gmail.com>
Subject: Re: WARNING in handle_mm_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzkaller <syzkaller@googlegroups.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Wed, Nov 25, 2015 at 6:37 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 25-11-15 18:21:02, Dmitry Vyukov wrote:
> [...]
>> I have some progress.
>
> Please have a look at Peter's patch posted in the original email thread
> http://lkml.kernel.org/r/20151125150207.GM11639@twins.programming.kicks-ass.net

Yes, I've posted there as well. That patch should help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
