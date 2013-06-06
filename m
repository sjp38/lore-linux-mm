Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C5C226B003B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 03:36:11 -0400 (EDT)
Message-ID: <51B03C1F.4000501@parallels.com>
Date: Thu, 6 Jun 2013 11:37:03 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 00/35] kmemcg shrinkers
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <20130605160721.da995af82eb247ccf8f8537f@linux-foundation.org> <51B02347.60809@parallels.com> <20130606001855.48d9da2e.akpm@linux-foundation.org>
In-Reply-To: <20130606001855.48d9da2e.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>

On 06/06/2013 11:18 AM, Andrew Morton wrote:
> The shrinker stuff seems sensible and straightforward and I expect we
> can proceed with that at the normal pace.  The memcg changes struck me
> as being hairy as hell and I'd really like to see the other memcg
> people go through it carefully.
> 
> Of course, "new series" doesn't give you an easily accessible tree to
> target.  I could drop it all again to give you a clean shot at
> tomorrow's -next?
If you just keep them on top (not really sure how hard it is for you), I
can just remove them all and apply a new series on top.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
