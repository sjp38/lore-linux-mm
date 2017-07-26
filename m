Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5B876B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:50:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k190so217105927pgk.8
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:50:47 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b77si9703294pfk.391.2017.07.26.07.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 07:50:46 -0700 (PDT)
Date: Wed, 26 Jul 2017 15:50:17 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v4 1/4] mm, oom: refactor the TIF_MEMDIE usage
Message-ID: <20170726145017.GA24286@castle.DHCP.thefacebook.com>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-2-guro@fb.com>
 <20170726135622.GS2981@dhcp22.suse.cz>
 <20170726140607.GA20062@castle.DHCP.thefacebook.com>
 <20170726142434.GT2981@dhcp22.suse.cz>
 <20170726144408.GU2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170726144408.GU2981@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 26, 2017 at 04:44:08PM +0200, Michal Hocko wrote:
> On Wed 26-07-17 16:24:34, Michal Hocko wrote:
> [...]
> > Or if you prefer I can post it separately?
> 
> I've just tried to rebase relevant parts on top of the current mmotm
> tree and it needs some non-trivial updates. Would you mind if I post
> those patches with you on CC?

Sure.
Again, I'm not against your approach (and I've tried to rebase your patches,
and it worked well for me, although I didn't run any proper tests),
I just don't want to create an unnecessary dependancy here.

If your patchset will be accepted, it will be quite trivial to rebase
mine and vice-versa; they are not so dependant.

> I will comment on the rest of the series later. I have glanced through
> it and have to digest it some more before replying.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
