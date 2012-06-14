Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 4ACB46B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 06:07:57 -0400 (EDT)
Date: Thu, 14 Jun 2012 12:07:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 15/15] hugetlb/cgroup: add HugeTLB controller
 documentation
Message-ID: <20120614100755.GM27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339583254-895-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339583254-895-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 15:57:34, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

Minor nid below
> ---
>  Documentation/cgroups/hugetlb.txt |   45 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 45 insertions(+)
>  create mode 100644 Documentation/cgroups/hugetlb.txt
> 
> diff --git a/Documentation/cgroups/hugetlb.txt b/Documentation/cgroups/hugetlb.txt
> new file mode 100644
> index 0000000..a9faaca
> --- /dev/null
> +++ b/Documentation/cgroups/hugetlb.txt
[...]
> +With the above step, the initial or the parent HugeTLB group becomes
> +visible at /sys/fs/cgroup. At bootup, this group includes all the tasks in
> +the system. /sys/fs/cgroup/tasks lists the tasks in this cgroup.
> +
> +New groups can be created under the parent group /sys/fs/cgroup.
> +
> +# cd /sys/fs/cgroup
> +# mkdir g1
> +# echo $$ > g1/tasks
> +
> +The above steps create a new group g1 and move the current shell
> +process (bash) into it.

This is probably not needed as it is already described in the generic
cgroups description

> +
> +Brief summary of control files
> +
> + hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
> + hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
> + hugetlb.<hugepagesize>.usage_in_bytes     # show current res_counter usage for "hugepagesize" hugetlb
> + hugetlb.<hugepagesize>.failcnt		   # show the number of allocation failure due to HugeTLB limit
> +
> +For a system supporting two hugepage size (16M and 16G) the control
> +files include:
> +
> +hugetlb.16GB.limit_in_bytes
> +hugetlb.16GB.max_usage_in_bytes
> +hugetlb.16GB.usage_in_bytes
> +hugetlb.16GB.failcnt
> +hugetlb.16MB.limit_in_bytes
> +hugetlb.16MB.max_usage_in_bytes
> +hugetlb.16MB.usage_in_bytes
> +hugetlb.16MB.failcnt
> -- 
> 1.7.10
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
