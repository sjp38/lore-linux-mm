Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9D9206B01A5
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 12:49:36 -0500 (EST)
Received: by qcsd17 with SMTP id d17so4682151qcs.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:49:35 -0800 (PST)
Message-ID: <4EE63EA9.9060908@gmail.com>
Date: Mon, 12 Dec 2011 12:49:29 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix a typo in documentation
References: <1323476120-8964-1-git-send-email-yinghan@google.com> <20111212105134.GA18789@cmpxchg.org>
In-Reply-To: <20111212105134.GA18789@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

(12/12/11 5:51 AM), Johannes Weiner wrote:
> On Fri, Dec 09, 2011 at 04:15:20PM -0800, Ying Han wrote:
>> A tiny typo on mapped_file stat.
>>
>> Signed-off-by: Ying Han<yinghan@google.com>
>> ---
>>   Documentation/cgroups/memory.txt |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
>> index 070c016..c0f409e 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -410,7 +410,7 @@ hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
>>
>>   total_cache		- sum of all children's "cache"
>>   total_rss		- sum of all children's "rss"
>> -total_mapped_file	- sum of all children's "cache"
>> +total_mapped_file	- sum of all children's "mapped_file"
>>   total_mlock		- sum of all children's "mlock"
>>   total_pgpgin		- sum of all children's "pgpgin"
>>   total_pgpgout		- sum of all children's "pgpgout"
>
> Your fix obviously makes sense, but the line is still incorrect: it's
> not just the sum of all children but that of the full hierarchy
> starting with the consulted memcg.  It includes that memcg's local
> counter as well.  Aside from that, this all seems awefully redundant.
>
> How about this on top?
>
> ---
> From: Johannes Weiner<hannes@cmpxchg.org>
> Subject: [patch] Documentation: memcg: future proof hierarchical statistics
>   documentation
>
> The hierarchical versions of per-memcg counters in memory.stat are all
> calculated the same way and are all named total_<counter>.
>
> Documenting the pattern is easier for maintenance than listing each
> counter twice.
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
> ---
>   Documentation/cgroups/memory.txt |   15 ++++-----------
>   1 files changed, 4 insertions(+), 11 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 06eb6d9..a858675 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -404,17 +404,10 @@ hierarchical_memory_limit - # of bytes of memory limit with regard to hierarchy
>   hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
>   			hierarchy under which memory cgroup is.
>
> -total_cache		- sum of all children's "cache"
> -total_rss		- sum of all children's "rss"
> -total_mapped_file	- sum of all children's "mapped_file"
> -total_pgpgin		- sum of all children's "pgpgin"
> -total_pgpgout		- sum of all children's "pgpgout"
> -total_swap		- sum of all children's "swap"
> -total_inactive_anon	- sum of all children's "inactive_anon"
> -total_active_anon	- sum of all children's "active_anon"
> -total_inactive_file	- sum of all children's "inactive_file"
> -total_active_file	- sum of all children's "active_file"
> -total_unevictable	- sum of all children's "unevictable"
> +total_<counter>		- # hierarchical version of<counter>, which in
> +			addition to the cgroup's own value includes the
> +			sum of all hierarchical children's values of
> +			<counter>, i.e. total_cache
>

I like this.
  Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
