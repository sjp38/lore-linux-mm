Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C8A626B0027
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:03:32 -0400 (EDT)
Message-ID: <516384BC.7040302@huawei.com>
Date: Tue, 9 Apr 2013 11:02:20 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] memcg: convert to use cgroup->id
References: <51627DA9.7020507@huawei.com> <51627E33.4090107@huawei.com> <20130408145702.GM17178@dhcp22.suse.cz>
In-Reply-To: <20130408145702.GM17178@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 2013/4/8 22:57, Michal Hocko wrote:
> On Mon 08-04-13 16:22:11, Li Zefan wrote:
>> This is a preparation to kill css_id.
>>
>> Signed-off-by: Li Zefan <lizefan@huawei.com>
> 
> This patch depends on the following patch, doesn't it? There is no
> guarantee that id fits into short right now. Not such a big deal but
> would be nicer to have that guarantee for bisectability.
> 

Not necessary, because css_id still prevents us from creating too
many cgroups.

> The patch on its own looks good.
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
