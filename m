Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C08436B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:55:48 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so22640575wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 04:55:48 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id g7si43328333wjy.213.2015.07.29.04.55.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 04:55:47 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so217365291wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 04:55:46 -0700 (PDT)
Date: Wed, 29 Jul 2015 13:55:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC -v2] panic_on_oom_timeout
Message-ID: <20150729115543.GG15801@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <20150617121104.GD25056@dhcp22.suse.cz>
 <201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
 <20150617125127.GF25056@dhcp22.suse.cz>
 <20150617132427.GG25056@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150617132427.GG25056@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 17-06-15 15:24:27, Michal Hocko wrote:
> On Wed 17-06-15 14:51:27, Michal Hocko wrote:
> [...]
> > The important thing is to decide what is the reasonable way forward. We
> > have two two implementations of panic based timeout. So we should decide
> 
> And the most obvious question, of course.
> - Should we add a panic timeout at all?
> 
> > - Should be the timeout bound to panic_on_oom?
> > - Should we care about constrained OOM contexts?
> > - If yes should they use the same timeout?
> > - If yes should each memcg be able to define its own timeout?
>        ^ no
>  
> > My thinking is that it should be bound to panic_on_oom=1 only until we
> > hear from somebody actually asking for a constrained oom and even then
> > do not allow for too large configuration space (e.g. no per-memcg
> > timeout) or have separate mempolicy vs. memcg timeouts.
> > 
> > Let's start simple and make things more complicated later!

Any more ideas/thoughts on this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
