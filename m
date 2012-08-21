Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 13CC16B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 03:54:35 -0400 (EDT)
Date: Tue, 21 Aug 2012 09:54:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 09/11] memcg: propagate kmem limiting information to
 children
Message-ID: <20120821075430.GA19797@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-10-git-send-email-glommer@parallels.com>
 <20120817090005.GC18600@dhcp22.suse.cz>
 <502E0BC3.8090204@parallels.com>
 <20120817093504.GE18600@dhcp22.suse.cz>
 <502E17C4.7060204@parallels.com>
 <20120817103550.GF18600@dhcp22.suse.cz>
 <502E1E90.1080805@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502E1E90.1080805@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri 17-08-12 14:36:00, Glauber Costa wrote:
> On 08/17/2012 02:35 PM, Michal Hocko wrote:
> >> > But I never said that can't happen. I said (ok, I meant) the static
> >> > branches can't be disabled.
> > Ok, then I misunderstood that because the comment was there even before
> > static branches were introduced and it made sense to me. This is
> > inconsistent with what we do for user accounting because even if we set
> > limit to unlimitted we still account. Why should we differ here?
> 
> Well, we account even without a limit for user accounting. This is a
> fundamental difference, no ?

Yes, user memory accounting is either on or off all the time (switchable
at boot time). 
My understanding of kmem is that the feature is off by default because
it brings an overhead that is worth only special use cases. And that
sounds good to me. I do not see a good reason to have runtime switch
off. It makes the code more complicated for no good reason. E.g. how do
you handle charges you left behind? Say you charged some pages for
stack?

But maybe you have a good use case for that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
