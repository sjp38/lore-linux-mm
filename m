Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp103.postini.com [74.125.245.223])
	by kanga.kvack.org (Postfix) with SMTP id 425D06B007B
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:25:57 -0400 (EDT)
Message-ID: <501802DB.5030600@redhat.com>
Date: Tue, 31 Jul 2012 12:07:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
References: <1343687538-24284-1-git-send-email-yinghan@google.com> <20120731155932.GB16924@tiehlicka.suse.cz>
In-Reply-To: <20120731155932.GB16924@tiehlicka.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 07/31/2012 11:59 AM, Michal Hocko wrote:

>> @@ -1899,6 +1907,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>>   		}
>>   		memcg = mem_cgroup_iter(root, memcg,&reclaim);
>>   	} while (memcg);
>> +
>> +	if (!over_softlimit) {
>
> Is this ever false? At least root cgroup is always above the limit.
> Shouldn't we rather compare reclaimed pages?

Uh oh.

That could also result in us always reclaiming from the root cgroup
first...

Is that really what we want?

Having said that, in April I discussed an algorithm of LRU list
weighting with Ying and others that should work.  Ying's patches
look like a good basis to implement that on top of...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
