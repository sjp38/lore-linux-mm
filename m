Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 816256B00A6
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:26:58 -0400 (EDT)
Received: by wgv5 with SMTP id 5so65758815wgv.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:26:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si4107752wiv.47.2015.05.29.08.26.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 08:26:54 -0700 (PDT)
Date: Fri, 29 May 2015 17:26:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150529152652.GG22728@dhcp22.suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150528210742.GF27479@htj.duckdns.org>
 <20150529120838.GC22728@dhcp22.suse.cz>
 <20150529131055.GH27479@htj.duckdns.org>
 <20150529134553.GD22728@dhcp22.suse.cz>
 <20150529140737.GK27479@htj.duckdns.org>
 <20150529145739.GF22728@dhcp22.suse.cz>
 <20150529152328.GM27479@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529152328.GM27479@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 29-05-15 11:23:28, Tejun Heo wrote:
> Hello,
> 
> On Fri, May 29, 2015 at 04:57:39PM +0200, Michal Hocko wrote:
[...]
> > OK so you creat a task A (leader) which clones several tasks Pn with
> > CLONE_VM without CLONE_THREAD. Moving A around would control memcg
> > membership while Pn could be moved around freely to control membership
> > in other controllers (e.g. cpu to control shares). So it is something
> > like moving threads separately.
> 
> Sure, it'd behave clearly in certain cases but then again you'd have
> cases where how mm->owner changes isn't clear at all when seen from
> the userland. 

Sure. I am definitely _not_ advocating this use case! As said before, I
consider it abuse. It is just fair to point out this is a user visible
change IMO.

> e.g. When the original owner goes away, the assignment
> of the next owner is essentially arbitrary.  That's what I meant by
> saying it was already a crapshoot.  We should definitely document the
> change but this isn't likely to be an issue.  CLONE_VM &&
> !CLONE_THREAD is an extreme corner case to begin with and even the
> behavior there wasn't all that clearly defined.

That is the line of argumentation in my changelog ;)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
