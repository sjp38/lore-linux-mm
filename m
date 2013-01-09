Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 625B46B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 16:55:20 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz11so1295561pad.3
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 13:55:19 -0800 (PST)
Date: Wed, 9 Jan 2013 13:55:14 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130109215514.GD20454@htj.dyndns.org>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130109203731.GA20454@htj.dyndns.org>
 <50EDDF1E.6010705@parallels.com>
 <20130109213604.GA9475@lizard.fhda.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109213604.GA9475@lizard.fhda.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hello, Anton.

On Wed, Jan 09, 2013 at 01:36:04PM -0800, Anton Vorontsov wrote:
> On Thu, Jan 10, 2013 at 01:20:30AM +0400, Glauber Costa wrote:
> [...]
> > Given the above, I believe that ideally we should use this pressure
> > mechanism in memcg replacing the current memcg notification mechanism.
> 
> Just a quick wonder: why would we need to place it into memcg, when we
> don't need any of the memcg stuff for it? I see no benefits, not
> design-wise, not implementation-wise or anything-wise. :)

Maybe I'm misunderstanding the whole thing but how can memory pressure
exist apart from memcg when memcg is in use?  Memory limits, reclaim
and OOM are all per-memcg, how do you even define memory pressure?  If
ten tasks belong to a memcg w/ a lot of spare memory and one belongs
to another which is about to hit OOM, is that mempressure cgroup under
pressure?

> We can use mempressure w/o memcg, and even then it can (or should :) be
> useful (for cpuset, for example).

The problem is that you end with, at the very least, duplicate
hierarchical accounting mechanisms which overlap with each other
while, most likely, being slightly different.  About the same thing
happened with cpu and cpuacct controllers and we're now trying to
deprecate the latter.

Please talk with memcg people and fold it into memcg.  It can (and
should) be done in a way to not incur overhead when only root memcg is
in use and how this is done defines userland-visible interface, so
let's please not repeat past mistakes.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
