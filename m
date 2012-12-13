Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3E6376B0078
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 08:57:21 -0500 (EST)
Date: Thu, 13 Dec 2012 14:56:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 UPDATE] mm/hugetlb: create hugetlb cgroup file in
 hugetlb_init
Message-ID: <20121213135656.GB27775@dhcp22.suse.cz>
References: <50C94DE5.2040302@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C94DE5.2040302@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, tj@kernel.org, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, dhillf@gmail.com, Liujiang <jiang.liu@huawei.com>, Jiang Liu <liuj97@gmail.com>, qiuxishi <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org

On Thu 13-12-12 11:39:17, Jianguo Wu wrote:
> Build kernel with CONFIG_HUGETLBFS=y,CONFIG_HUGETLB_PAGE=y
> and CONFIG_CGROUP_HUGETLB=y, then specify hugepagesz=xx boot option,
> system will boot fail.
> 
> This failure is caused by following code path:
> setup_hugepagesz
> 	hugetlb_add_hstate
> 		hugetlb_cgroup_file_init
> 			cgroup_add_cftypes
> 				kzalloc <--slab is *not available* yet
> 
> For this path, slab is not available yet, so memory allocated will be
> failed, and cause WARN_ON() in hugetlb_cgroup_file_init().
> 
> So I move hugetlb_cgroup_file_init() into hugetlb_init().
> 
> Changelog:
>   do code refactor as suggesting by Aneesh
>   add Reviewed-by and Acked-by 
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Any reason to not add Cc: stable as I suggested earlier?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
