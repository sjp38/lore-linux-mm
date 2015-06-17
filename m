Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC9A6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 09:24:34 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so83153857wic.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 06:24:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id aq6si7838917wjc.144.2015.06.17.06.24.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 06:24:33 -0700 (PDT)
Date: Wed, 17 Jun 2015 15:24:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -v2] panic_on_oom_timeout
Message-ID: <20150617132427.GG25056@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <20150617121104.GD25056@dhcp22.suse.cz>
 <201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
 <20150617125127.GF25056@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150617125127.GF25056@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 17-06-15 14:51:27, Michal Hocko wrote:
[...]
> The important thing is to decide what is the reasonable way forward. We
> have two two implementations of panic based timeout. So we should decide

And the most obvious question, of course.
- Should we add a panic timeout at all?

> - Should be the timeout bound to panic_on_oom?
> - Should we care about constrained OOM contexts?
> - If yes should they use the same timeout?
> - If yes should each memcg be able to define its own timeout?
       ^ no
 
> My thinking is that it should be bound to panic_on_oom=1 only until we
> hear from somebody actually asking for a constrained oom and even then
> do not allow for too large configuration space (e.g. no per-memcg
> timeout) or have separate mempolicy vs. memcg timeouts.
> 
> Let's start simple and make things more complicated later!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
