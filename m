Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 8A3C96B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 04:35:06 -0400 (EDT)
Date: Tue, 21 Aug 2012 10:35:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 09/11] memcg: propagate kmem limiting information to
 children
Message-ID: <20120821083501.GC19797@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-10-git-send-email-glommer@parallels.com>
 <20120817090005.GC18600@dhcp22.suse.cz>
 <502E0BC3.8090204@parallels.com>
 <20120817093504.GE18600@dhcp22.suse.cz>
 <502E17C4.7060204@parallels.com>
 <20120817103550.GF18600@dhcp22.suse.cz>
 <502E1E90.1080805@parallels.com>
 <20120821075430.GA19797@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120821075430.GA19797@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue 21-08-12 09:54:30, Michal Hocko wrote:
> E.g. how do you handle charges you left behind? Say you charged some
> pages for stack?

I got to the last patch and see how you do it. You are relying on
free_accounted_pages directly which doesn't check kmem_accounted and
uses PageUsed bit instead. So this is correct. I guess you are relying
on the life cycle of the object in general so other types of objects
should be safe as well and there shouldn't be any leaks. It is just that
the memcg life time is not bounded now. Will think about that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
