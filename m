Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B3EF96B0006
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 14:03:56 -0400 (EDT)
Message-ID: <516AEF81.4090508@redhat.com>
Date: Sun, 14 Apr 2013 14:03:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone shrinking
 code
References: <1365509595-665-1-git-send-email-mhocko@suse.cz> <1365509595-665-2-git-send-email-mhocko@suse.cz> <20130414004252.GA1330@suse.de> <20130414143420.GA6478@dhcp22.suse.cz> <20130414145532.GB5701@cmpxchg.org> <20130414150455.GE6478@dhcp22.suse.cz>
In-Reply-To: <20130414150455.GE6478@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>

On 04/14/2013 11:04 AM, Michal Hocko wrote:
> On Sun 14-04-13 10:55:32, Johannes Weiner wrote:

>> I think what Mel suggests is not to return the highest excessor, but
>> return the highest parent in the hierarchy that is in excess.  Once
>> you have this parent, you know that all children are in excess,
>> without looking them up individually.
>
> OK, I see it now.
>
>> However, that parent is not necessarily the root of the hierarchy that
>> is being reclaimed and you might have multiple of such sub-hierarchies
>> in excess.  To handle all the corner cases, I'd expect the
>> relationship checking to get really complicated.
>
> We could always return the leftmost and get to others as the iteration
> continues. I will try to think about it some more. I do not think we
> would save a lot but it looks like a neat idea.

We should probably gather around a whiteboard this week in
San Francisco, and figure out what exactly we want the code
to do, before figuring out the most efficient way to do it.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
