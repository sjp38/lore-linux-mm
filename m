Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 29A406B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 13:55:18 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so474995pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 10:55:17 -0700 (PDT)
Date: Tue, 26 Jun 2012 10:55:13 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] fix bad behavior in use_hierarchy file
Message-ID: <20120626175513.GO3869@google.com>
References: <1340616061-1955-1-git-send-email-glommer@parallels.com>
 <20120625204908.GL3869@google.com>
 <20120626075653.GD6713@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626075653.GD6713@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, devel@openvz.org, Dhaval Giani <dhaval.giani@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, gthelen@google.com

Hello,

On Tue, Jun 26, 2012 at 09:56:53AM +0200, Michal Hocko wrote:
> [Adding Ying to CC - they are using hierarchies AFAIU in their workloads]

Ooh, I'm they. :) Asking around.... okay, so google does use
.use_hierarchy but it's a tree-wide thing and would be perfectly happy
with a global switch.

> On Mon 25-06-12 13:49:08, Tejun Heo wrote:
> [...]
> > A bit of delta but is there any chance we can either deprecate
> > .use_hierarhcy or at least make it global toggle instead of subtree
> > thing?  
> 
> So what you are proposing is to have all subtrees of the root either
> hierarchical or not, right?

Yeap.  Just make it a global switch.  Probably determined on mount
time.

> > This seems needlessly complicated. :(
> 
> Toggle wouldn't help much I am afraid. We would still have to
> distinguish (non)hierarchical cases. And I am not sure we can make
> everything hierarchical easily. 

I'm kinda confused by this paragraph.  What do you mean by "wouldn't
help much"?  Do you mean in terms of complexity?

> Most users (from my experience) ignored use_hierarchy for some reasons
> and the end results might be really unexpected for them if they used
> deeper subtrees (which might be needed due to combination with other
> controller(s)).

Oh yeah, we can't change the default behavior like that.  The
transition should be a lot more gradual.  Even if making
.use_hierarchy doesn't help much in terms of reducing complexity right
now, it would at least allow us to weed out and prevent wacky woo-hoo
mom-look-at-what-I-can-do configurations which will be a lot more
difficult to deal with for both us and such users (if we end up
forcing hierarchy).

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
