Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CD0B36B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 12:57:18 -0400 (EDT)
Received: by mail-qe0-f46.google.com with SMTP id f6so2836751qej.19
        for <linux-mm@kvack.org>; Fri, 17 May 2013 09:57:17 -0700 (PDT)
Date: Fri, 17 May 2013 09:57:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130517165712.GB12632@mtj.dyndns.org>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
 <1368431172-6844-2-git-send-email-mhocko@suse.cz>
 <20130517160247.GA10023@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130517160247.GA10023@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

Hello, Johannes.

On Fri, May 17, 2013 at 12:02:47PM -0400, Johannes Weiner wrote:
> There are setups with thousands of groups that do not even use soft
> limits.  Having them pointlessly iterate over all of them for every
> couple of pages reclaimed is just not acceptable.

Hmmm... if the iteration is the problem, it shouldn't be difficult to
build list of children which should be iterated.  Would that make it
acceptable?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
