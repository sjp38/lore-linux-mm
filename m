Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id BAF996B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 02:22:17 -0400 (EDT)
Message-ID: <509367F5.9060801@cn.fujitsu.com>
Date: Fri, 02 Nov 2012 14:28:05 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART6 Patch] mempolicy: fix is_valid_nodemask()
References: <1351675458-11859-1-git-send-email-wency@cn.fujitsu.com> <1351675458-11859-2-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1210311119000.8809@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210311119000.8809@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

At 11/01/2012 02:21 AM, David Rientjes Wrote:
> On Wed, 31 Oct 2012, Wen Congyang wrote:
> 
>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>>
>> is_valid_nodemask() is introduced by 19770b32. but it does not match
>> its comments, because it does not check the zone which > policy_zone.
>>
>> Also in b377fd, this commits told us, if highest zone is ZONE_MOVABLE,
>> we should also apply memory policies to it. so ZONE_MOVABLE should be valid zone
>> for policies. is_valid_nodemask() need to be changed to match it.
>>
>> Fix: check all zones, even its zoneid > policy_zone.
>> Use nodes_intersects() instead open code to check it.
>>
> 
> This changes the semantics of MPOL_BIND to be considerably different than 
> what it is today: slab allocations are no longer bound by such a policy 
> which isn't consistent with what userspace expects or is specified by 
> set_mempolicy() and there's no way, with your patch, to actually specify 
> that we don't care about ZONE_MOVABLE and that the slab allocations 
> _should_ actually be allocated on movable-only zones.  You have to respect 
> cases where people aren't interested in node hotplug and not cause a 
> regression.
> 

Should we allow the user to bind a task to a node which has only ZONE_MOVABLE memory?

Thanks
Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
