Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 427436B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:05:50 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so170720080pac.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 02:05:50 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id zx6si49596877pbc.51.2015.11.16.02.05.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 02:05:49 -0800 (PST)
Received: by pacej9 with SMTP id ej9so64064401pac.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 02:05:49 -0800 (PST)
Date: Mon, 16 Nov 2015 02:05:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/7] mm/gfp: make gfp_zonelist return directly and bool
In-Reply-To: <1447656686-4851-7-git-send-email-baiyaowei@cmss.chinamobile.com>
Message-ID: <alpine.DEB.2.10.1511160205010.18751@chino.kir.corp.google.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com> <1447656686-4851-7-git-send-email-baiyaowei@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 16 Nov 2015, Yaowei Bai wrote:

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 6523109..1da03f5 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -375,12 +375,9 @@ static inline enum zone_type gfp_zone(gfp_t flags)
>   * virtual kernel addresses to the allocated page(s).
>   */
>  
> -static inline int gfp_zonelist(gfp_t flags)
> +static inline bool gfp_zonelist(gfp_t flags)
>  {
> -	if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
> -		return 1;
> -
> -	return 0;
> +	return IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE);
>  }
>  
>  /*

This function is used to index into a pgdat's node_zonelists[] array, bool 
makes no sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
