Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 3B1586B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 21:10:20 -0400 (EDT)
Message-ID: <51F07AAB.2040607@huawei.com>
Date: Thu, 25 Jul 2013 09:08:59 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/8] cgroup: convert cgroup_ida to cgroup_idr
References: <51EFA554.6080801@huawei.com> <51EFA570.5020907@huawei.com> <20130724140702.GD2540@dhcp22.suse.cz>
In-Reply-To: <20130724140702.GD2540@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 2013/7/24 22:07, Michal Hocko wrote:
> On Wed 24-07-13 17:59:12, Li Zefan wrote:
>> This enables us to lookup a cgroup by its id.
>>
>> Signed-off-by: Li Zefan <lizefan@huawei.com>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks for the review! I'll wait a couple of days for other comments,
and then update the patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
