Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 471986B002B
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 08:48:13 -0500 (EST)
Message-ID: <50A4F289.1090807@parallels.com>
Date: Thu, 15 Nov 2012 17:47:53 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] memcg: get rid of once-per-second cache shrinking
 for dead memcgs
References: <1352948093-2315-1-git-send-email-glommer@parallels.com> <1352948093-2315-6-git-send-email-glommer@parallels.com> <50A4B8C8.6020202@jp.fujitsu.com>
In-Reply-To: <50A4B8C8.6020202@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

On 11/15/2012 01:41 PM, Kamezawa Hiroyuki wrote:
> (2012/11/15 11:54), Glauber Costa wrote:
>> The idea is to synchronously do it, leaving it up to the shrinking
>> facilities in vmscan.c and/or others. Not actively retrying shrinking
>> may leave the caches alive for more time, but it will remove the ugly
>> wakeups. One would argue that if the caches have free objects but are
>> not being shrunk, it is because we don't need that memory yet.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Andrew Morton <akpm@linux-foundation.org>
> 
> I agree this patch but can we have a way to see the number of unaccounted
> zombie cache usage for debugging ?
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Any particular interface in mind ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
