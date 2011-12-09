Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 694EE6B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 07:41:37 -0500 (EST)
Message-ID: <4EE201DE.9040102@parallels.com>
Date: Fri, 9 Dec 2011 10:41:02 -0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 2/9] foundations of per-cgroup memory pressure controlling.
References: <1323120903-2831-1-git-send-email-glommer@parallels.com> <1323120903-2831-3-git-send-email-glommer@parallels.com> <20111209102438.2db705d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111209102438.2db705d0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz

On 12/08/2011 11:24 PM, KAMEZAWA Hiroyuki wrote:
> On Mon,  5 Dec 2011 19:34:56 -0200
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> This patch replaces all uses of struct sock fields' memory_pressure,
>> memory_allocated, sockets_allocated, and sysctl_mem to acessor
>> macros. Those macros can either receive a socket argument, or a mem_cgroup
>> argument, depending on the context they live in.
>>
>> Since we're only doing a macro wrapping here, no performance impact at all is
>> expected in the case where we don't have cgroups disabled.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>> CC: Eric Dumazet<eric.dumazet@gmail.com>
>
> please get ack from network guys.
> from me.
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
Ok.

I think that now with all the Reviewed-by:'s I will resend it as a 
Request for Inclusion for Dave (plus fixing the problem you noted in 
patch 1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
