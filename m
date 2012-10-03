Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D4F006B009D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:59:39 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so11833749pbb.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 15:59:39 -0700 (PDT)
Date: Thu, 4 Oct 2012 07:59:30 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20121003225930.GF19248@localhost>
References: <20120927142822.GG3429@suse.de>
 <20120927144942.GB4251@mtj.dyndns.org>
 <50646977.40300@parallels.com>
 <20120927174605.GA2713@localhost>
 <50649EAD.2050306@parallels.com>
 <20120930075700.GE10383@mtj.dyndns.org>
 <20120930080249.GF10383@mtj.dyndns.org>
 <1348995388.2458.8.camel@dabdike.int.hansenpartnership.com>
 <20120930103732.GK10383@mtj.dyndns.org>
 <5069584A.8090809@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5069584A.8090809@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Mon, Oct 01, 2012 at 12:46:02PM +0400, Glauber Costa wrote:
> > Yeah, it will need some hooks.  For dentry and inode, I think it would
> > be pretty well isolated tho.  Wasn't it?
> 
> We would still need something for the stack. For open files, and for
> everything that becomes a potential problem. We then end up with 35
> different knobs instead of one. One of the perceived advantages of this
> approach, is that it condenses as much data as a single knob as
> possible, reducing complexity and over flexibility.

Oh, I didn't mean to use object-specific counting for all of them.
Most resources don't have such common misaccounting problem.  I mean,
for stack, it doesn't exist by definition (other than cgroup
migration).  There's no reason to use anything other than first-use
kmem based accounting for them.  My point was that for particularly
problematic ones like dentry/inode, it might be better to treat them
differently.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
