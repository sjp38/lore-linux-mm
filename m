Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 4EDEC6B0008
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 01:28:09 -0500 (EST)
Message-ID: <5100D485.4020302@parallels.com>
Date: Thu, 24 Jan 2013 10:28:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: reduce the size of struct memcg 244-fold.
References: <1358962426-8738-1-git-send-email-glommer@parallels.com> <20130123161810.73e4ca58.akpm@linux-foundation.org>
In-Reply-To: <20130123161810.73e4ca58.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>


>>  	struct mem_cgroup *memcg;
>> -	int size = sizeof(struct mem_cgroup);
>> +	int size = memcg_size();
>>  
>> -	/* Can be very big if MAX_NUMNODES is very big */
>> +	/* Can be very big if nr_node_ids is very big */
>>  	if (size < PAGE_SIZE)
>>  		memcg = kzalloc(size, GFP_KERNEL);
>>  	else
>> @@ -5933,7 +5943,7 @@ out_free:
>>  static void __mem_cgroup_free(struct mem_cgroup *memcg)
>>  {
>>  	int node;
>> -	int size = sizeof(struct mem_cgroup);
>> +	int size = memcg_size();
>>  
>>  	mem_cgroup_remove_from_trees(memcg);
>>  	free_css_id(&mem_cgroup_subsys, &memcg->css);
> 
> Really everything here should be using size_t - a minor
> cosmetic/readability thing.
> 
I agree

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
