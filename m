Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60A866B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 06:42:33 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t15so4308788wmh.3
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 03:42:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si10628462wrq.373.2017.12.11.03.42.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 03:42:31 -0800 (PST)
Date: Mon, 11 Dec 2017 12:42:29 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second
 allocation
Message-ID: <20171211114229.GA4779@dhcp22.suse.cz>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171207115127.GH20234@dhcp22.suse.cz>
 <201712072059.HAJ04643.QSJtVMFLFOOOHF@I-love.SAKURA.ne.jp>
 <20171207122249.GI20234@dhcp22.suse.cz>
 <201712081958.EBB43715.FOVJQFtFLOMOSH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712081958.EBB43715.FOVJQFtFLOMOSH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

On Fri 08-12-17 19:58:11, Tetsuo Handa wrote:
[...]
> Therefore, I'm stuck between Michal and Johannes. And I updated "mm,oom: use
> ALLOC_OOM for OOM victim's last second allocation" not to depend on "mm,oom:
> move last second allocation to inside the OOM killer".

No, you seem to be stuck elsewhere. You keep ignoring that the OOM
killer is a best effort heuristic to free up some memory. And as any
other heuristic it has to balance cons and pros. One of the biggest
argument in those decision is how _serious_ the problem is another tweak
worth all the possible downfalls?

You keep repeating Manish report which is an _artificial_ OOM scenario.
It is true that we can do better in that case but the real solution
looks differently - we should make mlocked memory reapable. Now that is
not a trivial thing to do and I still have that on my todo list. You are
actively avoiding the real solution by providing tweaks (try one more
time) here and there. I really hate that approach. This will make the
behavior time dependant as Johannes pointed out.

I was OK with your "move the last allocation attempt" because it
conceptually makes some sense at least. Johannes had arguments against
and I do respect them because I do agree it is not a general and
_measurable_ win. And this is how the consensus based develoment works.
We are not pushing for questionable solutions unless there is an
absolute urge for that because the issue is serious and many users
suffer from it yet there is no real solution in sight. See the
difference?

That being said, I will keep refusing other such tweaks unless you have
a sound usecase behind. If you really _want_ to help out here then you
can focus on the reaping of the mlock memory.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
