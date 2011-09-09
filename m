Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 35677900138
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 08:02:27 -0400 (EDT)
Message-ID: <4E6A001C.2040600@parallels.com>
Date: Fri, 9 Sep 2011 09:01:32 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 6/9] per-cgroup tcp buffers control
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-7-git-send-email-glommer@parallels.com> <20110909121206.e1d628d1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110909121206.e1d628d1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>

On 09/09/2011 12:12 AM, KAMEZAWA Hiroyuki wrote:
> On Wed,  7 Sep 2011 01:23:16 -0300
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> With all the infrastructure in place, this patch implements
>> per-cgroup control for tcp memory pressure handling.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>
> Hmm, then, kmem_cgroup.c is just a caller of plugins implemented
> by other components ?

Kame,

Refer to my discussion with Greg. How would you feel about it being 
accounted to a single "kernel memory" limit in memcg?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
