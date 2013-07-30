Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 56E8E6B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:23:03 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id s11so854772qcv.6
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 07:23:02 -0700 (PDT)
Date: Tue, 30 Jul 2013 10:22:59 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/8] cgroup: document how cgroup IDs are assigned
Message-ID: <20130730142252.GJ12016@htj.dyndns.org>
References: <51F614B2.6010503@huawei.com>
 <51F614D4.6000703@huawei.com>
 <20130729182632.GC26076@mtj.dyndns.org>
 <51F711FE.3040006@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F711FE.3040006@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jul 30, 2013 at 09:08:14AM +0800, Li Zefan wrote:
> On 2013/7/30 2:26, Tejun Heo wrote:
> > On Mon, Jul 29, 2013 at 03:08:04PM +0800, Li Zefan wrote:
> >> As cgroup id has been used in netprio cgroup and will be used in memcg,
> >> it's important to make it clear how a cgroup id is allocated.
> >>
> >> For example, in netprio cgroup, the id is used as index of anarray.
> >>
> >> Signed-off-by: Li Zefan <lizefan@huwei.com>
> >> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > 
> > We can merge this into the first patch?
> > 
> 
> The first patch just changes ida to idr, it doesn't change how IDs are
> allocated, so I prefer make this a standalone patch.

Hmmm... I'd just add "while at it, add a comment explaining ..." to
the description and fold it into the prev patch but no biggie.  Please
do as you see fit.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
