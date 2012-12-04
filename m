Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id DD3F26B0068
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 04:01:00 -0500 (EST)
Date: Tue, 4 Dec 2012 10:00:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: debugging facility to access dangling memcgs.
Message-ID: <20121204090058.GF31319@dhcp22.suse.cz>
References: <1354541048-12597-1-git-send-email-glommer@parallels.com>
 <20121203154420.661f8e28.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121203154420.661f8e28.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Mon 03-12-12 15:44:20, Andrew Morton wrote:
> On Mon,  3 Dec 2012 17:24:08 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
> > If memcg is tracking anything other than plain user memory (swap, tcp
> > buf mem, or slab memory), it is possible - and normal - that a reference
> > will be held by the group after it is dead. Still, for developers, it
> > would be extremely useful to be able to query about those states during
> > debugging.
> > 
> > This patch provides a debugging facility in the root memcg, so we can
> > inspect which memcgs still have pending objects, and what is the cause
> > of this state.
> 
> As this is a developer-only thing, I suggest that we should avoid
> burdening mainline with it.  How about we maintain this in -mm (and
> hence in -next and mhocko's memcg tree) until we no longer see a need
> for it?

Yes, that makes sense. It can produce some conflicts but they should be
trivial to resolve.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
