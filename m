Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E1CD26B0037
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 10:27:43 -0400 (EDT)
Message-ID: <51B09C91.4010104@parallels.com>
Date: Thu, 6 Jun 2013 18:28:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 08/35] list: add a new LRU list type
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-9-git-send-email-glommer@openvz.org> <20130605160758.19e854a6995e3c2a1f5260bf@linux-foundation.org> <20130606024909.GP29338@dastard>
In-Reply-To: <20130606024909.GP29338@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes
 Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On 06/06/2013 06:49 AM, Dave Chinner wrote:
>> > How [patch 09/35]'s inode_lru_isolate() avoids this bug I don't know. 
>> > Perhaps it doesn't.
> The LRU_RETRY cse is supposed to handle this. However, the LRU_RETRY
> return code is now buggy and you've caught that. It'll need fixing.
> My original code only had inode_lru_isolate() drop the lru lock, and
> it would return LRU_RETRY which would restart the scan of the list
> from the start, thereby avoiding those problems.
> 
Yes, I have changed that, but I wasn't aware that your original
intention for restarting from the beginning was to avoid such problems.
And having only half the brain Andrew has, I didn't notice it myself.

I will fix this somehow while trying to keep the behavior Mel insisted
on; iow; not retrying forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
