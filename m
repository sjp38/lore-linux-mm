Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 30D396B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 12:17:50 -0400 (EDT)
Message-ID: <501BF98B.9030103@redhat.com>
Date: Fri, 03 Aug 2012 12:17:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V8 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
References: <1343942664-13365-1-git-send-email-yinghan@google.com> <20120803140224.GC8434@dhcp22.suse.cz>
In-Reply-To: <20120803140224.GC8434@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/03/2012 10:02 AM, Michal Hocko wrote:
> On Thu 02-08-12 14:24:24, Ying Han wrote:
		shrink_lruvec(lruvec, sc);
>>
>> +			if (!mem_cgroup_is_root(memcg))
>> +				over_softlimit = true;
>> +		}
>> +
>
> I think this is still not sufficient because you do not want to hammer
> root in the ignore_softlimit case.

Michal, please see my mail from a few days ago, describing how I
plan to balance pressure between the various LRU lists.

I hope to throw a prototype patch over the wall soon...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
