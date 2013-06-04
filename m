Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A7CBB6B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 16:54:31 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id t10so789562pdi.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 13:54:30 -0700 (PDT)
Date: Tue, 4 Jun 2013 13:54:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130604205426.GI14916@htj.dyndns.org>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <1370254735-13012-5-git-send-email-mhocko@suse.cz>
 <20130604010737.GF29989@mtj.dyndns.org>
 <20130604134523.GH31242@dhcp22.suse.cz>
 <20130604193619.GA14916@htj.dyndns.org>
 <20130604204807.GA13231@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604204807.GA13231@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

Hey,

On Tue, Jun 04, 2013 at 10:48:07PM +0200, Michal Hocko wrote:
> > I really don't think memcg can afford to add more mess than there
> > already is.  Let's try to get things right with each change, please.
> 
> Is this really about inside vs. outside skipping? I think this is a
> general improvement to the code. I really prefer not duplicating common
> code and skipping handling is such a code (we have a visitor which can
> control the walk). With a side bonus that it doesn't have to pollute
> vmscan more than necessary.
> 
> Please be more specific about _what_ is so ugly about this interface so
> that it matters so much.

Can you please try the other approach and see how it looks?  It's just
my general experience that you usually end up with something much
uglier when you try to do much inside an iterator and having to add
callbacks which need to communicate through enums is usually a pretty
good sign that it took a wrong turn somewhere.  There sure are cases
where such approach is necessary but I really don't see it here.  So,
it'd be really great if you can give a shot.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
