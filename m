Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 960A26B015C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:56:56 -0400 (EDT)
Date: Tue, 26 Jun 2012 09:56:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] fix bad behavior in use_hierarchy file
Message-ID: <20120626075653.GD6713@tiehlicka.suse.cz>
References: <1340616061-1955-1-git-send-email-glommer@parallels.com>
 <20120625204908.GL3869@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120625204908.GL3869@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, devel@openvz.org, Dhaval Giani <dhaval.giani@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

[Adding Ying to CC - they are using hierarchies AFAIU in their workloads]

On Mon 25-06-12 13:49:08, Tejun Heo wrote:
[...]
> A bit of delta but is there any chance we can either deprecate
> .use_hierarhcy or at least make it global toggle instead of subtree
> thing?  

So what you are proposing is to have all subtrees of the root either
hierarchical or not, right?

> This seems needlessly complicated. :(

Toggle wouldn't help much I am afraid. We would still have to
distinguish (non)hierarchical cases. And I am not sure we can make
everything hierarchical easily. 
Most users (from my experience) ignored use_hierarchy for some reasons
and the end results might be really unexpected for them if they used
deeper subtrees (which might be needed due to combination with other
controller(s)).
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
