Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id C3C1B6B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 02:05:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CB5283EE0C1
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 15:05:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B42DF45DE5F
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 15:05:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A27545DE5E
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 15:05:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DA951DB8054
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 15:05:33 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44E581DB804A
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 15:05:33 +0900 (JST)
Message-ID: <50936288.5090008@jp.fujitsu.com>
Date: Fri, 02 Nov 2012 15:04:56 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART6 Patch] mempolicy: fix is_valid_nodemask()
References: <1351675458-11859-1-git-send-email-wency@cn.fujitsu.com> <1351675458-11859-2-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1210311119000.8809@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210311119000.8809@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

(2012/11/01 3:21), David Rientjes wrote:
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

I'm sorry if I misunderstand somehing....
I think people doesn't insterested in node-hotplug will never have MOVABLE_ZONE.
What causes regression ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
