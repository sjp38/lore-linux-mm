Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7D0586B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 09:33:48 -0400 (EDT)
Message-ID: <4F5F4C48.8050001@parallels.com>
Date: Tue, 13 Mar 2012 17:31:52 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V3 3/8] hugetlb: add charge/uncharge calls for HugeTLB
 alloc/free
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On 03/13/2012 11:07 AM, Aneesh Kumar K.V wrote:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8cac77b..f4aa11c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2901,6 +2901,11 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>
>   	if (PageSwapCache(page))
>   		return NULL;
> +	/*
> +	 * HugeTLB page uncharge happen in the HugeTLB compound page destructor
> +	 */
> +	if (PageHuge(page))
> +		return NULL;

Maybe it is better to call uncharge_common from the compound destructor,
so we can have all the uncharge code in a single place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
