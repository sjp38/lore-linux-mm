Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 4D5146B004D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 06:07:05 -0500 (EST)
Message-ID: <4EDF48A9.6090306@parallels.com>
Date: Wed, 7 Dec 2011 09:06:17 -0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 0/9] per-cgroup tcp memory pressure controls
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1323120903-2831-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz

On 12/05/2011 07:34 PM, Glauber Costa wrote:
> Hi,
>
> This is my new attempt to fix all the concerns that were raised during
> the last iteration.
>
> I should highlight:
> 1) proc information is kept intact. (although I kept the wrapper functions)
>     it will be submitted as a follow up patch so it can get the attention it
>     deserves
> 2) sockets now hold a reference to memcg. sockets can be alive even after the
>     task is gone, so we don't bother with between cgroups movements.
>     To be able to release resources more easily in this cenario, the parent
>     pointer in struct cg_proto was replaced by a memcg object. We then iterate
>     through its pointer (which is cleaner anyway)
>
> The rest should be mostly the same except for small fixes and style changes.
>

Kame,

Does this one address your previous concerns?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
