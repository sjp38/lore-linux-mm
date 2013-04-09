Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id C27BC6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:30:51 -0400 (EDT)
Message-ID: <51638B2B.4010305@huawei.com>
Date: Tue, 9 Apr 2013 11:29:47 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] cgroup: implement cgroup_is_ancestor()
References: <51627DA9.7020507@huawei.com> <51627DBB.5050005@huawei.com> <51638947.9060303@jp.fujitsu.com>
In-Reply-To: <51638947.9060303@jp.fujitsu.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 2013/4/9 11:21, Kamezawa Hiroyuki wrote:
> (2013/04/08 17:20), Li Zefan wrote:
>> This will be used as a replacement for css_is_ancestor().
>>
>> Signed-off-by: Li Zefan <lizefan@huawei.com>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Hmm....but do we need "depth" ?
> 

which was removed in Tejun's
"[PATCHSET] perf, cgroup: implement hierarchy support for perf_event controller"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
