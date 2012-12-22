Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 99A456B005A
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 18:57:04 -0500 (EST)
Message-ID: <50D648BF.7070103@parallels.com>
Date: Sun, 23 Dec 2012 03:56:47 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] vmscan: take at least one pass with shrinkers
References: <1356086810-6950-1-git-send-email-glommer@parallels.com> <1356086810-6950-3-git-send-email-glommer@parallels.com> <20121222235340.GI15182@dastard>
In-Reply-To: <20121222235340.GI15182@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On 12/23/2012 03:53 AM, Dave Chinner wrote:
> On Fri, Dec 21, 2012 at 02:46:50PM +0400, Glauber Costa wrote:
>> In very low free kernel memory situations, it may be the case that we
>> have less objects to free than our initial batch size. If this is the
>> case, it is better to shrink those, and open space for the new workload
>> then to keep them and fail the new allocations.
>>
>> More specifically, this happens because we encode this in a loop with
>> the condition: "while (total_scan >= batch_size)". So if we are in such
>> a case, we'll not even enter the loop.
>>
>> This patch modifies turns it into a do () while {} loop, that will
>> guarantee that we scan it at least once, while keeping the behaviour
>> exactly the same for the cases in which total_scan > batch_size.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> Acked-by: Dave Chinner <david@fromorbit.com>
> 
> I think you'll find I said:
> 
> Reviewed-by: Dave Chinner <dchinner@redhat.com>
> 
> That has a significantly different meaning to Acked-by, so you
> should be careful to correctly transcribe tags back to the
> patches...
> 

Ooops

You are right Dave. That was obviously just lack of attention on my
side, not any attempt to upgrade your tag.

Thanks for spotting


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
