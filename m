Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E13A56B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 14:06:50 -0500 (EST)
Message-ID: <51115821.4020100@parallels.com>
Date: Tue, 5 Feb 2013 23:06:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
References: <1359009996-5350-1-git-send-email-glommer@parallels.com> <20130205185324.GB6481@cmpxchg.org> <20130205190454.GC3959@dhcp22.suse.cz>
In-Reply-To: <20130205190454.GC3959@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On 02/05/2013 11:04 PM, Michal Hocko wrote:
> On Tue 05-02-13 13:53:24, Johannes Weiner wrote:
> [...]
>> Subject: [patch] memcg: reduce the size of struct memcg 244-fold morrr fix
>>
>> Remove struct mem_cgroup_lru_info.  It only holds the nodeinfo array
>> and is actively misleading because there is all kinds of per-node
>> stuff in addition to the LRU info in there.  On that note, remove the
>> incorrect comment as well.
>>
>> Move comment about the nodeinfo[0] array having to be the last field
>> in struct mem_cgroup after said array.  Should be more visible when
>> attempting to append new members to the struct.
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Yes, I like this. The info level is just artificatial and without any
> good reason.
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
