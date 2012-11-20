Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 5B4F66B0089
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:34:37 -0500 (EST)
Message-ID: <50AB4095.6000502@parallels.com>
Date: Tue, 20 Nov 2012 12:34:29 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg
 is disabled
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com> <50AB05B4.4000303@jp.fujitsu.com>
In-Reply-To: <50AB05B4.4000303@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On 11/20/2012 08:23 AM, Kamezawa Hiroyuki wrote:
> (2012/11/20 10:44), David Rientjes wrote:
>> While profiling numa/core v16 with cgroup_disable=memory on the command
>> line, I noticed mem_cgroup_count_vm_event() still showed up as high as
>> 0.60% in perftop.
>>
>> This occurs because the function is called extremely often even when
>> memcg
>> is disabled.
>>
>> To fix this, inline the check for mem_cgroup_disabled() so we avoid the
>> unnecessary function call if memcg is disabled.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Acked-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
I am fine with this as well.

Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
