Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD5D8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:45:10 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n23-v6so2137772qkn.19
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:45:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w11-v6si1033997qts.264.2018.09.12.09.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 09:45:09 -0700 (PDT)
Date: Wed, 12 Sep 2018 18:45:05 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Message-ID: <20180912164505.GA18706@redhat.com>
References: <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp>
 <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz>
 <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
 <20180906115320.GS14951@dhcp22.suse.cz>
 <CACT4Y+byA7dLar5=9y+7RApT2WdxgVA9c29q83NEVkd5KCLgjg@mail.gmail.com>
 <20180906121601.GU14951@dhcp22.suse.cz>
 <20180911163708.GB27989@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180911163708.GB27989@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On 09/11, Oleg Nesterov wrote:
>
> On 09/06, Michal Hocko wrote:
> >
> > So a question for Oleg I guess. Is it possible that for_each_process
> > live locks (or stalls for way too long/unbounded amount of time) under
> > heavy fork/exit loads?
>
> Oh yes, it can... plus other problems.
>
> I even sent the initial patches which introduce for_each_process_break/continue
> a long ago... I'll try to find them tommorrow and resend.

Two years ago ;) I don't understand why there were ignored, please see
"[PATCH 0/2] introduce for_each_process_thread_break() and for_each_process_thread_continue()"
I sent a minute ago.

However, I didn't notice that the subject mentions oom/dump_tasks... As for
dump_tasks() it probably doesn't need the new helpers, I'll write another email
tomorrow, but perhaps the time limit is all we need.

Oleg.
