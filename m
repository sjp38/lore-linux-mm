Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43DCF6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 07:55:28 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m5so18527578qtb.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:55:28 -0700 (PDT)
Received: from mail-qt0-f173.google.com (mail-qt0-f173.google.com. [209.85.216.173])
        by mx.google.com with ESMTPS id a189si18918733qke.59.2016.10.19.04.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 04:55:27 -0700 (PDT)
Received: by mail-qt0-f173.google.com with SMTP id q7so15392216qtq.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:55:27 -0700 (PDT)
Date: Wed, 19 Oct 2016 13:55:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: How to make warn_alloc() reliable?
Message-ID: <20161019115525.GH7517@dhcp22.suse.cz>
References: <201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp>
 <20161018122749.GE12092@dhcp22.suse.cz>
 <201610192027.GFB17670.VOtOLQFFOSMJHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201610192027.GFB17670.VOtOLQFFOSMJHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 19-10-16 20:27:53, Tetsuo Handa wrote:
[...]
> What I'm talking about is "why don't you stop playing whack-a-mole games
> with missing warn_alloc() calls". I don't blame you for not having a good
> idea, but I blame you for not having a reliable warn_alloc() mechanism.

Look, it seems pretty clear that our priorities and viewes are quite
different. While I believe that we should solve real issues in a
reliable and robust way you seem to love to be have as much reporting as
possible. I do agree that reporting is important part of debugging of
problems but as your previous attempts for the allocation watchdog show
a proper and bullet proof reporting requires state tracking and is in
general too complex for something that doesn't happen in most properly
configured systems. Maybe there are other ways but my time is better
spent on something more useful - like making the direct reclaim path
more deterministic without any unbound loops.

So let's agree to disagree about importance of the reliability
warn_alloc. I see it as an improvement which doesn't really have to be
perfect.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
