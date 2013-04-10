Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id AF8236B0027
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:30:02 -0400 (EDT)
Message-ID: <51651518.4010007@parallels.com>
Date: Wed, 10 Apr 2013 11:30:32 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-3-git-send-email-glommer@parallels.com> <20130408084202.GA21654@lge.com> <51628412.6050803@parallels.com> <20130408090131.GB21654@lge.com> <51628877.5000701@parallels.com> <20130409005547.GC21654@lge.com> <20130409012931.GE17758@dastard> <20130409020505.GA4218@lge.com> <20130409123008.GM17758@dastard> <20130410025115.GA5872@lge.com>
In-Reply-To: <20130410025115.GA5872@lge.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On 04/10/2013 06:51 AM, Joonsoo Kim wrote:
> As you can see, before this patch, do_shrinker_shrink() for
> "huge_zero_page_shrinker" is not called until we call shrink_slab() more
> than 13 times. *Frequency* we call do_shrinker_shrink() actually is
> largely different with before. With this patch, we actually call
> do_shrinker_shrink() for "huge_zero_page_shrinker" 12 times more
> than before. Can we be convinced that there will be no problem?
> 
> This is why I worry about this change.
> Am I worried too much? :)

Yes, you are. The amount of times shrink_slab is called is completely
unpredictable. Changing the size of cached data structures is a lot more
likely to change this than this shrinker change, for instance.

Not to mention, the amount of times shrink_slab() is called is not
changed directly here. But rather, the amount of times an individual
shrinker actually does work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
