Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E8FC96B0025
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 05:18:44 -0500 (EST)
Message-ID: <5107A211.50409@parallels.com>
Date: Tue, 29 Jan 2013 14:18:57 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/6] memcg: bypass swap accounting for the root memcg
References: <510658EE.9050006@oracle.com>
In-Reply-To: <510658EE.9050006@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, handai.szj@taobao.com

On 01/28/2013 02:54 PM, Jeff Liu wrote:
> Root memcg with swap cgroup is special since we only do tracking but can
> not set limits against it.  In order to facilitate the implementation of
> the coming swap cgroup structures delay allocation mechanism, we can bypass
> the default swap statistics upon the root memcg and figure it out through
> the global stats instead as below:
> 
I am sorry if this is was already discussed before, but:
> root_memcg_swap_stat: total_swap_pages - nr_swap_pages - used_swap_pages_of_all_memcgs
> memcg_total_swap_stats: root_memcg_swap_stat + other_memcg_swap_stats
> 

Shouldn't it *at least* be dependent on use_hierarchy?

I don't see why root_memcg won't be always total_swap_pages -
nr_swap_pages, since the root memcg is always viewed as a superset of
the others, AFAIR.

Even if it is not the general case (which again, I really believe it
is), it certainly is the case for hierarchy enabled setups.

Also, I truly don't understand what is the business of
root_memcg_swap_stat in non-root memcgs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
