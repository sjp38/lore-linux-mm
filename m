Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B539F6B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 09:35:36 -0400 (EDT)
Message-ID: <4F5F4CD0.3080207@parallels.com>
Date: Tue, 13 Mar 2012 17:34:08 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V3 4/8] memcg: track resource index in cftype private
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331622432-24683-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On 03/13/2012 11:07 AM, Aneesh Kumar K.V wrote:
>   		if (type == _MEM)
>   			ret = mem_cgroup_resize_limit(memcg, val);
> -		else
> +		else if (type == _MEMHUGETLB) {
> +			int idx = MEMFILE_IDX(cft->private);
> +			ret = res_counter_set_limit(&memcg->hugepage[idx], val);
> +		} else
>   			ret = mem_cgroup_resize_memsw_limit(memcg, val);
>   		break;
>   	case RES_SOFT_LIMIT:

What if a user try to set limit < usage ? Isn't there any reclaim that 
we could possibly do, like it is done by normal memcg ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
