Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE6036B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:44:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q50so32046361wrb.14
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:44:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n20si9487710wmi.28.2017.07.26.07.44.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 07:44:11 -0700 (PDT)
Date: Wed, 26 Jul 2017 16:44:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 1/4] mm, oom: refactor the TIF_MEMDIE usage
Message-ID: <20170726144408.GU2981@dhcp22.suse.cz>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-2-guro@fb.com>
 <20170726135622.GS2981@dhcp22.suse.cz>
 <20170726140607.GA20062@castle.DHCP.thefacebook.com>
 <20170726142434.GT2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726142434.GT2981@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 26-07-17 16:24:34, Michal Hocko wrote:
[...]
> Or if you prefer I can post it separately?

I've just tried to rebase relevant parts on top of the current mmotm
tree and it needs some non-trivial updates. Would you mind if I post
those patches with you on CC? I really think that we shouldn't invent a
new throttling just to replace it later.

I will comment on the rest of the series later. I have glanced through
it and have to digest it some more before replying.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
