Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 6D17C6B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 20:46:09 -0400 (EDT)
Message-ID: <4F8625AD.6000707@redhat.com>
Date: Wed, 11 Apr 2012 20:45:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 3/5] memcg: set soft_limit_in_bytes to 0 by default
References: <1334181614-26836-1-git-send-email-yinghan@google.com>
In-Reply-To: <1334181614-26836-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On 04/11/2012 06:00 PM, Ying Han wrote:
> 1. If soft_limit are all set to MAX, it wastes first three periority iterations
> without scanning anything.
>
> 2. By default every memcg is eligibal for softlimit reclaim, and we can also
> set the value to MAX for special memcg which is immune to soft limit reclaim.
>
> This idea is based on discussion with Michal and Johannes from LSF.

Combined with patch 2/5, would this not result in always
returning "reclaim from this memcg" for groups without a
configured softlimit, while groups with a configured
softlimit only get reclaimed from when they are over
their limit?

Is that the desired behaviour when a system has some
cgroups with a configured softlimit, and some without?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
