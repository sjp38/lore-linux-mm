Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 42F926B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 06:35:55 -0400 (EDT)
Date: Fri, 17 Aug 2012 12:35:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 09/11] memcg: propagate kmem limiting information to
 children
Message-ID: <20120817103550.GF18600@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-10-git-send-email-glommer@parallels.com>
 <20120817090005.GC18600@dhcp22.suse.cz>
 <502E0BC3.8090204@parallels.com>
 <20120817093504.GE18600@dhcp22.suse.cz>
 <502E17C4.7060204@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502E17C4.7060204@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri 17-08-12 14:07:00, Glauber Costa wrote:
> On 08/17/2012 01:35 PM, Michal Hocko wrote:
> >>> Above you said "Once enabled, can't be disabled." and now you can
> >>> > > disable it? Say you are a leaf group with non accounted parents. This
> >>> > > will clear the flag and so no further accounting is done. Shouldn't
> >>> > > unlimited mean that we will never reach the limit? Or am I missing
> >>> > > something?
> >>> > >
> >> > 
> >> > You are missing something, and maybe I should be more clear about that.
> >> > The static branches can't be disabled (it is only safe to disable them
> >> > from disarm_static_branches(), when all references are gone). Note that
> >> > when unlimited, we flip bits, do a transversal, but there is no mention
> >> > to the static branch.
> > My little brain still doesn't get this. I wasn't concerned about static
> > branches. I was worried about memcg_can_account_kmem which will return
> > false now, doesn't it.
> > 
> 
> Yes, it will. If I got you right, you are concerned because I said that
> can't happen. But it will.
> 
> But I never said that can't happen. I said (ok, I meant) the static
> branches can't be disabled.

Ok, then I misunderstood that because the comment was there even before
static branches were introduced and it made sense to me. This is
inconsistent with what we do for user accounting because even if we set
limit to unlimitted we still account. Why should we differ here?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
