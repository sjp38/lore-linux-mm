Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D15098E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 12:37:12 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e88-v6so25317124qtb.1
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 09:37:12 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g2-v6si8412945qvn.38.2018.09.11.09.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 09:37:12 -0700 (PDT)
Date: Tue, 11 Sep 2018 18:37:09 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Message-ID: <20180911163708.GB27989@redhat.com>
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp>
 <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz>
 <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
 <20180906115320.GS14951@dhcp22.suse.cz>
 <CACT4Y+byA7dLar5=9y+7RApT2WdxgVA9c29q83NEVkd5KCLgjg@mail.gmail.com>
 <20180906121601.GU14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906121601.GU14951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On 09/06, Michal Hocko wrote:
>
> Ccing Oleg.

Thanks, but somehow I can't find this patch on marc.info ...

> So a question for Oleg I guess. Is it possible that for_each_process
> live locks (or stalls for way too long/unbounded amount of time) under
> heavy fork/exit loads?

Oh yes, it can... plus other problems.

I even sent the initial patches which introduce for_each_process_break/continue
a long ago... I'll try to find them tommorrow and resend.

Oleg.
