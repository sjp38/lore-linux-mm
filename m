Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB2E828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:18:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so48934124lfg.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:18:41 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id w203si7205598wme.93.2016.04.14.08.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 08:18:40 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id y144so23748610wmd.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:18:39 -0700 (PDT)
Date: Thu, 14 Apr 2016 17:18:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Clarify reason to kill other threads sharing
 thevitctim's memory.
Message-ID: <20160414151838.GK2850@dhcp22.suse.cz>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1460631391-8628-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160414113108.GE2850@dhcp22.suse.cz>
 <201604150003.GAI13041.MLHFOtOFOQSJVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604150003.GAI13041.MLHFOtOFOQSJVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

On Fri 15-04-16 00:03:31, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > I would rather be explicit that we _do not care_
> > about these configurations. It is just PITA maintain and it doesn't make
> > any sense. So rather than trying to document all the weird thing that
> > might happen I would welcome a warning "mm shared with OOM_SCORE_ADJ_MIN
> > task. Something is broken in your configuration!"
> 
> Would you please stop rejecting configurations which do not match your values?

Can you point out a single real life example where the above
configuration would make a sense? This is not about _my_ values. This is
about general _sanity_. If two/more entities share the mm and they disagree
about their OOM priorities then something is clearly broken. Don't you think?
How can the OOM killer do anything sensible here? The API we have
created is broken because it allows broken configurations too easily. It
is too late to fix it though so we can only rely on admins to use it
sensibly.

So please try to step back and think about whether it actually make
sense to make the oom even more complex/confusing for something that
gives little (if any) sense.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
