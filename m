Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 2EA186B0037
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 11:04:33 -0400 (EDT)
Date: Fri, 21 Jun 2013 17:04:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130621150430.GL12424@dhcp22.suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130620111206.GA14809@suse.de>
 <20130621140627.GI12424@dhcp22.suse.cz>
 <20130621140938.GJ12424@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130621140938.GJ12424@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Fri 21-06-13 16:09:38, Michal Hocko wrote:
> On Fri 21-06-13 16:06:27, Michal Hocko wrote:
> [...]
> > > Can you try this monolithic patch please?
> > 
> > Wow, this looks much better!
> 
> Damn it! Scratch that. I have made a mistake in configuration so this
> all has been 0-no-limit in fact. Sorry about that. It's only now that
> I've noticed that so I am retesting. Hopefully it will be done before I
> leave today. I will post it on Monday otherwise.

And for real now and it is still Wow!
* 0-limit
er
base: min: 1188.28 max: 1198.54 avg: 1194.10 std: 3.31 runs: 6
baserebase: min: 1186.17 [99.8%] max: 1196.46 [99.8%] avg: 1189.75 [99.6%] std: 3.41 runs: 6
mel: min: 989.99 [83.3%] max: 993.35 [82.9%] avg: 991.71 [83.1%] std: 1.18 runs: 6
System
base: min: 248.40 max: 252.00 avg: 250.19 std: 1.38 runs: 6
baserebase: min: 240.77 [96.9%] max: 246.74 [97.9%] avg: 243.63 [97.4%] std: 2.23 runs: 6
mel: min: 144.75 [58.3%] max: 148.27 [58.8%] avg: 146.97 [58.7%] std: 1.41 runs: 6
Elapsed
base: min: 759.28 max: 805.30 avg: 784.87 std: 15.45 runs: 6
baserebase: min: 881.69 [116.1%] max: 938.14 [116.5%] avg: 911.68 [116.2%] std: 19.58 runs: 6
mel: min: 365.99 [48.2%] max: 376.12 [46.7%] avg: 369.82 [47.1%] std: 4.04 runs: 6

* no-limit
User
base: min: 1164.94 max: 1169.75 avg: 1168.31 std: 1.57 runs: 6
baserebase: min: 1169.46 [100.4%] max: 1176.07 [100.5%] avg: 1172.49 [100.4%] std: 2.38 runs: 6
mel: min: 990.96 [85.1%] max: 994.18 [85.0%] avg: 992.79 [85.0%] std: 1.15 runs: 6
System
base: min: 242.55 max: 245.36 avg: 243.92 std: 1.17 runs: 6
baserebase: min: 235.36 [97.0%] max: 238.52 [97.2%] avg: 236.70 [97.0%] std: 1.04 runs: 6
mel: min: 148.40 [61.2%] max: 150.77 [61.4%] avg: 149.33 [61.2%] std: 0.97 runs: 6
Elapsed
base: min: 596.81 max: 620.04 avg: 605.52 std: 7.56 runs: 6
baserebase: min: 666.45 [111.7%] max: 710.89 [114.7%] avg: 690.62 [114.1%] std: 13.85 runs: 6
mel: min: 365.27 [61.2%] max: 371.40 [59.9%] avg: 369.43 [61.0%] std: 2.26 runs: 6
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
