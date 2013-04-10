Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 101D26B0037
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:32:01 -0400 (EDT)
Message-ID: <51651596.7090903@parallels.com>
Date: Wed, 10 Apr 2013 11:32:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-3-git-send-email-glommer@parallels.com> <515936B5.8070501@jp.fujitsu.com> <515940E4.8050704@parallels.com> <5164F416.8040903@gmail.com>
In-Reply-To: <5164F416.8040903@gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On 04/10/2013 09:09 AM, Ric Mason wrote:
>> Before it, we will try to shrink 512 objects and succeed at 0 (because
>> > batch is 1024). After this, we will try to free 512 objects and succeed
>> > at an undefined quantity between 0 and 512.
> Where you get the magic number 512 and 1024? The value of SHRINK_BATCH
> is 128.
> 
This is shrinker-defined. For instance, the super-block shrinker reads:

                s->s_shrink.shrink = prune_super;
                s->s_shrink.batch = 1024;

And then vmscan:
                long batch_size = shrinker->batch ? shrinker->batch
                                                  : SHRINK_BATCH;

I am dealing too much with the super block shrinker these days, so I
just had that cached in my mind and forgot to check the code and be more
explicit.

In any case, that was a numeric example that is valid nevertheless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
