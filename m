Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD40C6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 11:51:43 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c195so10180866itb.4
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 08:51:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e97sor8189015ioi.1.2017.10.05.08.51.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 08:51:42 -0700 (PDT)
Date: Thu, 5 Oct 2017 08:51:38 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [v10 5/6] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20171005155138.GU3301751@devbig577.frc2.facebook.com>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-6-guro@fb.com>
 <20171004200453.GE1501@cmpxchg.org>
 <20171005131419.4o6qynsl2qxomekb@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005131419.4o6qynsl2qxomekb@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Michal.

On Thu, Oct 05, 2017 at 03:14:19PM +0200, Michal Hocko wrote:
> Yes and that is why I think a boot time knob would be the most simple
> way. It will also open doors for more oom policies in future which I
> believe come sooner or later.

While boot params are fine for development and debugging, as a
user-interface, they aren't great.

* The user can't easily confirm whether the config they input is
  correct and when they get it wrong what's wrong can be pretty
  mysterious.

* While kernel params can be made r/w through /proc, people usually
  don't expect that and using that can become really confusing because
  a lot of people use "dmesg|grep" to confirm the boot params and that
  won't agree with the setting written later.

* It can't be scoped.  What if we want to choose different policies
  per delegated subtree?

* Boot params aren't the easiest (again, if you're a developer,
  they're but most aren't developers) to play with and prone to cause
  deployment issues.

* In this case, even worse because it ends up silently ignoring a
  clearly explicit configuration in an interface file.

If the behavior differences we get from group oom code isn't critical
(and it doesn't seem to be), I'd greatly prefer just enabling it when
cgroup2 is in use.  If it absolutely must be opt-in even on cgroup2,
we can discuss other ways but I'd really like to see stronger
rationales before going that route.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
