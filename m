Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 32D8E900117
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 01:44:37 -0400 (EDT)
Message-ID: <4E8A9D04.7060002@parallels.com>
Date: Tue, 4 Oct 2011 09:43:32 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 4/8] per-cgroup tcp buffers control
References: <1317637123-18306-1-git-send-email-glommer@parallels.com> <1317637123-18306-5-git-send-email-glommer@parallels.com> <20111004101633.6b44201d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111004101633.6b44201d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

On 10/04/2011 05:16 AM, KAMEZAWA Hiroyuki wrote:
> It seems memcg->tcp.tcp_memory_pressure has no locks and not atomic.
>
> no problematic race ?
>
> Thanks,
> -Kame
Well,

prior to this patch, it was a global variable. And nobody complained so 
far...

My impression is that the only thing that really needs to be atomic is
the memory accounting, which is already. If we miss a memory pressure 
condition entry, we'll get to it next time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
