Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0679F6B0007
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:44:03 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o20so8824813wro.3
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 04:44:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e203si3750041wmd.36.2018.02.12.04.44.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Feb 2018 04:44:01 -0800 (PST)
Date: Mon, 12 Feb 2018 13:43:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible deadlock in v4.14.15 contention on shrinker_rwsem in
 shrink_slab()
Message-ID: <20180212124359.GB3443@dhcp22.suse.cz>
References: <4e9300f9-14c4-84a9-2258-b7e52bb6f753@I-love.SAKURA.ne.jp>
 <alpine.LRH.2.11.1801272305200.20457@mail.ewheeler.net>
 <201801290527.w0T5RsPg024008@www262.sakura.ne.jp>
 <201802031648.EBH81222.QOSOFVOMtJFHLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201802031648.EBH81222.QOSOFVOMtJFHLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@lists.ewheeler.net, linux-mm@kvack.org, kirill@shutemov.name, minchan@kernel.org, tj@kernel.org, agk@redhat.com, snitzer@redhat.com, kent.overstreet@gmail.com

On Sat 03-02-18 16:48:28, Tetsuo Handa wrote:
> Michal, what do you think? If no comment, let's try page_owner + SystemTap
> and check whether there are some characteristics with stalling pages.

I am sorry, I was on vacation and now catching up. So I will not get to
this anytime soon. Next week hopefully, but I cannot promise anything.

I am not sure page_owner will help us much here. We know this is a shmem
page. Pagelock tracking is quite a PITA so a bisection sounds like a
less PITA even though the reproduction might take quite a lot of time.
Another approach would be to reduce the problem space, e.g. rule out
zram by using a different swap storage.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
