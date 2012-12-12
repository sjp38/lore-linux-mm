Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 1F98F6B005D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 07:48:21 -0500 (EST)
Date: Wed, 12 Dec 2012 13:48:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/hugetlb: create hugetlb cgroup file in hugetlb_init
Message-ID: <20121212124817.GF32081@dhcp22.suse.cz>
References: <50C83F97.3040009@huawei.com>
 <20121212101917.GD32081@dhcp22.suse.cz>
 <50C85FFD.10305@huawei.com>
 <20121212112329.GE32081@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121212112329.GE32081@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, tj@kernel.org, lizefan@huawei.com, aneesh.kumar@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, dhillf@gmail.com, Jiang Liu <liuj97@gmail.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org

On Wed 12-12-12 12:23:29, Michal Hocko wrote:
> On Wed 12-12-12 18:44:13, Xishi Qiu wrote:
[...]
> > Hi Michal,
> > 
> > __initcall functions will be called in
> > start_kernel()
> > 	rest_init()  // -> slab is already
> > 		kernel_init()
> > 			kernel_init_freeable()
> > 				do_basic_setup()
> > 					do_initcalls()
> > 
> > and setup_hugepagesz() will be called in
> > start_kernel()
> > 	parse_early_param()  // -> before mm_init() -> kmem_cache_init()
> > 
> > Is this right?
> 
> Yes this is right. I just noticed that kmem_cache_init_late is an __init
> function as well and didn't realize it is called directly. Sorry about
> the confusion.
> Anyway I still think it would be a better idea to move the call into the
> hugetlb_cgroup_create callback where it is more logical IMO but now that
> I'm looking at other controllers (blk and kmem.tcp) they all do this from
> init calls as well. So it doesn't make sense to have hugetlb behave
> differently.
> 
> So
> Acked-by: Michal Hocko <mhocko@suse.cz>

Ohh, and this deserves to be backported to stable (since 3.6).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
