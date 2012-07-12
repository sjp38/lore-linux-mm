Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 425AC6B007D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 03:18:28 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3992886pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 00:18:27 -0700 (PDT)
Message-ID: <4FFE7A3D.3010908@gmail.com>
Date: Thu, 12 Jul 2012 15:18:21 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 2/5] mm, oom: introduce helper function to process threads
 during scan
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291405360.6040@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206291405360.6040@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On 06/30/2012 05:06 AM, David Rientjes wrote:
> This patch introduces a helper function to process each thread during the
> iteration over the tasklist.  A new return type, enum oom_scan_t, is
> defined to determine the future behavior of the iteration:
>
>   - OOM_SCAN_OK: continue scanning the thread and find its badness,
>
>   - OOM_SCAN_CONTINUE: do not consider this thread for oom kill, it's
>     ineligible,
>
>   - OOM_SCAN_ABORT: abort the iteration and return, or
>
>   - OOM_SCAN_SELECT: always select this thread with the highest badness
>     possible.
>
> There is no functional change with this patch.  This new helper function
> will be used in the next patch in the memory controller.
>

Looks good to me.
You can add  Reviewed-by: Sha Zhengju <handai.szj@taobao.com> :-)


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
