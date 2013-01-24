Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2620A6B0002
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 02:51:59 -0500 (EST)
Message-ID: <5100E82A.3060608@parallels.com>
Date: Thu, 24 Jan 2013 11:52:10 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
References: <1359009996-5350-1-git-send-email-glommer@parallels.com> <xr93r4lbrpdk.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93r4lbrpdk.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>


>> +static inline size_t memcg_size(void)
>> +{
>> +	return sizeof(struct mem_cgroup) +
>> +		nr_node_ids * sizeof(struct mem_cgroup_per_node);
>> +}
>> +
> 
> Tangential question: why use inline here?  I figure that modern
> compilers are good at making inlining decisions.
I was born last century.

No reason, really. Just habit.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
