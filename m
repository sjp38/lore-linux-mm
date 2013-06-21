Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7D9326B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 10:09:45 -0400 (EDT)
Date: Fri, 21 Jun 2013 16:09:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130621140938.GJ12424@dhcp22.suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130620111206.GA14809@suse.de>
 <20130621140627.GI12424@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130621140627.GI12424@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Fri 21-06-13 16:06:27, Michal Hocko wrote:
[...]
> > Can you try this monolithic patch please?
> 
> Wow, this looks much better!

Damn it! Scratch that. I have made a mistake in configuration so this
all has been 0-no-limit in fact. Sorry about that. It's only now that
I've noticed that so I am retesting. Hopefully it will be done before I
leave today. I will post it on Monday otherwise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
