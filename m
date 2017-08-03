Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A18196B0679
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 04:21:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k68so1268785wmd.14
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 01:21:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f66si934943wmd.164.2017.08.03.01.21.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 01:21:05 -0700 (PDT)
Date: Thu, 3 Aug 2017 10:21:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: do not rely on TIF_MEMDIE for memory
 reserves access
Message-ID: <20170803082104.GE12521@dhcp22.suse.cz>
References: <20170727090357.3205-2-mhocko@kernel.org>
 <201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
 <20170801165242.GA15518@dhcp22.suse.cz>
 <201708031039.GDG05288.OQJOHtLVFMSFFO@I-love.SAKURA.ne.jp>
 <20170803070606.GA12521@dhcp22.suse.cz>
 <201708031703.HGC35950.LSJFOHQFtFMOVO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708031703.HGC35950.LSJFOHQFtFMOVO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-08-17 17:03:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Look, I really appreciate your sentiment for for nommu platform but with
> > an absolute lack of _any_ oom reports on that platform that I am aware
> > of nor any reports about lockups during oom I am less than thrilled to
> > add a code to fix a problem which even might not exist. Nommu is usually
> > very special with a very specific workload running (e.g. no overcommit)
> > so I strongly suspect that any OOM theories are highly academic.
> 
> If you believe that there is really no oom report, get rid of the OOM
> killer completely.

I am not an user or even an owner of such a platform. As I've said all I
care about is to not regress for those guys and I believe that the patch
doesn't change nommu behavior in any risky way. If yes, point them out
and I will try to address them.
 
> > All I do care about is to not regress nommu as much as possible. So can
> > we get back to the proposed patch and updates I have done to address
> > your review feedback please?
> 
> No unless we get rid of the OOM killer if CONFIG_MMU=n.

Are you saying that you are going to nack the patch based on this
reasoning? This is just ridiculous.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
