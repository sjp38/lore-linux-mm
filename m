Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5C26B0275
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 08:57:33 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so4482088wic.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:57:32 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id k6si22210068wiw.1.2015.10.19.05.57.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 05:57:32 -0700 (PDT)
Received: by wikq8 with SMTP id q8so4582655wik.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:57:31 -0700 (PDT)
Date: Mon, 19 Oct 2015 14:57:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silent hang up caused by pages being not scanned?
Message-ID: <20151019125729.GG11998@dhcp22.suse.cz>
References: <201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
 <CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
 <20151015131409.GD2978@dhcp22.suse.cz>
 <20151016155716.GF19597@dhcp22.suse.cz>
 <CA+55aFynmzy=3f5ae6iAYC7o_27C1UkNzn9x4OFjrW6j6bV9rw@mail.gmail.com>
 <201510170349.FFE52187.OOSJFMOVHQFtLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510170349.FFE52187.OOSJFMOVHQFtLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Sat 17-10-15 03:49:39, Tetsuo Handa wrote:
> Linus Torvalds wrote:
> > Tetsuo, mind trying it out and maybe tweaking it a bit for the load
> > you have? Does it seem to improve on your situation?
> 
> Yes, I already tried it and just replied to Michal.
> 
> I tested for one hour using various memory stressing programs.
> As far as I tested, I did not hit silent hang up (

Thank you for your testing!

[...]

> Only problem I felt is that the ratio of inactive_file/writeback
> (shown below) was high (compared to shown above) when I did

Yes this is the lack of congestion on the bdi as Linus expected.
Another patch I've just posted should help in that regards. At least it
seems to help in my testing.

[...]

> I can still hit OOM livelock (
> 
>  MemAlloc-Info: X stalling task, Y dying task, Z victim task.
> 
> where X > 0 && Y > 0).

This seems a separate issue, though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
