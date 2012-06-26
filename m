Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 933F06B0131
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:04:53 -0400 (EDT)
Received: by yenr5 with SMTP id r5so4385277yen.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 23:04:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE9289B.2050105@jp.fujitsu.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <4FE9289B.2050105@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 02:04:32 -0400
Message-ID: <CAHGf_=q5qOudHJoXqCULkNjy_80r8_7UXQnKgYsu9sV8Kn0RPA@mail.gmail.com>
Subject: Re: [patch 1/3] mm, oom: move declaration for mem_cgroup_out_of_memory
 to oom.h
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, Jun 25, 2012 at 11:12 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/06/26 10:47), David Rientjes wrote:
>>
>> mem_cgroup_out_of_memory() is defined in mm/oom_kill.c, so declare it in
>> linux/oom.h rather than linux/memcontrol.h.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
