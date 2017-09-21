Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBA5F6B0268
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 04:30:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q75so9226865pfl.1
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 01:30:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i2sor365169pgn.194.2017.09.21.01.30.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 01:30:47 -0700 (PDT)
Date: Thu, 21 Sep 2017 01:30:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170918150254.GA24257@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1709210128020.10026@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz> <20170913215607.GA19259@castle> <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz> <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz> <20170915152301.GA29379@castle> <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com> <20170915210807.GA5238@castle> <20170918062045.kcfsboxvfmlg2wjo@dhcp22.suse.cz>
 <20170918150254.GA24257@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 18 Sep 2017, Roman Gushchin wrote:

> > As said in other email. We can make priorities hierarchical (in the same
> > sense as hard limit or others) so that children cannot override their
> > parent.
> 
> You mean they can set the knob to any value, but parent's value is enforced,
> if it's greater than child's value?
> 
> If so, this sounds logical to me. Then we have size-based comparison and
> priority-based comparison with similar rules, and all use cases are covered.
> 
> Ok, can we stick with this design?
> Then I'll return oom_priorities in place, and post a (hopefully) final version.
> 

I just want to make sure that we are going with your original 
implementation here: that oom_priority is only effective for compare 
sibling memory cgroups and nothing beyond that.  The value alone has no 
relationship to any ancestor.  We can't set oom_priority based on the 
priorities of any other memory cgroups other than our own siblings because 
we have no control over how those change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
