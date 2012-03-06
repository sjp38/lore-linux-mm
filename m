Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 43BD16B002C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 06:47:43 -0500 (EST)
Message-ID: <4F55F916.1020502@parallels.com>
Date: Tue, 6 Mar 2012 15:46:30 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mm/memcg: scanning_global_lru means mem_cgroup_disabled
References: <20120229090748.29236.35489.stgit@zurg> <20120229091539.29236.57783.stgit@zurg> <20120302141251.4f434632.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120302141251.4f434632.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/02/2012 09:12 AM, KAMEZAWA Hiroyuki wrote:
> On Wed, 29 Feb 2012 13:15:39 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> From: Hugh Dickins<hughd@google.com>
>>
>> Although one has to admire the skill with which it has been concealed,
>> scanning_global_lru(mz) is actually just an interesting way to test
>> mem_cgroup_disabled().  Too many developer hours have been wasted on
>> confusing it with global_reclaim(): just use mem_cgroup_disabled().
>>
>> Signed-off-by: Hugh Dickins<hughd@google.com>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> Acked-by: KAMEZWA Hiroyuki<kamezawa.hiroyu@jp.fujitu.com>
>
>
Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
