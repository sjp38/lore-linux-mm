Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B46176B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:41:45 -0400 (EDT)
Received: by lahd3 with SMTP id d3so2239205lah.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 22:41:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502DD6DF.6070404@parallels.com>
References: <1345150434-30957-1-git-send-email-yinghan@google.com>
	<502DD6DF.6070404@parallels.com>
Date: Thu, 16 Aug 2012 22:41:43 -0700
Message-ID: <CALWz4iwYTkg9q-PSp-N3pBBooauQyi8CcM0vUeW5rNg-dAZj2A@mail.gmail.com>
Subject: Re: [RFC PATCH 2/6] memcg: add target_mem_cgroup, mem_cgroup fields
 to shrink_control
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Thu, Aug 16, 2012 at 10:30 PM, Glauber Costa <glommer@parallels.com> wrote:
> On 08/17/2012 12:53 AM, Ying Han wrote:
>> Add target_mem_cgroup and mem_cgroup to shrink_control. The former one is the
>> "root" memcg under pressure, and the latter one is the "current" memcg under
>> pressure.
>>
>> The target_mem_cgroup is initialized with the scan_control's target_mem_cgroup
>> under target reclaim and default to NULL for rest of the places including
>> global reclaim.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> Maybe I'll change my mind while I advance in the patchset, but at first,
> I don't see the point in having two memcg encoded in the shrinker
> structure. It seems to me we should be able to do this internally from
> memcg and hide it from the shrinker code.

We can do something like scan_control has, and during shrink_zone()
passes down the memcg context with lruvec. That is feasible as
long as it is necessary.

--Ying
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
