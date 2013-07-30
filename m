Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 5FB126B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 21:08:54 -0400 (EDT)
Message-ID: <51F711FE.3040006@huawei.com>
Date: Tue, 30 Jul 2013 09:08:14 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/8] cgroup: document how cgroup IDs are assigned
References: <51F614B2.6010503@huawei.com> <51F614D4.6000703@huawei.com> <20130729182632.GC26076@mtj.dyndns.org>
In-Reply-To: <20130729182632.GC26076@mtj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 2013/7/30 2:26, Tejun Heo wrote:
> On Mon, Jul 29, 2013 at 03:08:04PM +0800, Li Zefan wrote:
>> As cgroup id has been used in netprio cgroup and will be used in memcg,
>> it's important to make it clear how a cgroup id is allocated.
>>
>> For example, in netprio cgroup, the id is used as index of anarray.
>>
>> Signed-off-by: Li Zefan <lizefan@huwei.com>
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 
> We can merge this into the first patch?
> 

The first patch just changes ida to idr, it doesn't change how IDs are
allocated, so I prefer make this a standalone patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
