Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 14F046B009E
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 08:52:15 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so11557441wgg.9
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 05:52:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ne11si3853907wic.77.2014.03.12.05.52.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 05:52:14 -0700 (PDT)
Date: Wed, 12 Mar 2014 13:52:13 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/8] mm: memcg: inline mem_cgroup_charge_common()
Message-ID: <20140312125213.GB11831@dhcp22.suse.cz>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
 <1394587714-6966-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394587714-6966-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 11-03-14 21:28:29, Johannes Weiner wrote:
[...]
> @@ -3919,20 +3919,21 @@ out:
>  	return ret;
>  }
>  
> -/*
> - * Charge the memory controller for page usage.
> - * Return
> - * 0 if the charge was successful
> - * < 0 if the cgroup is over its limit
> - */
> -static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask, enum charge_type ctype)
> +int mem_cgroup_newpage_charge(struct page *page,
> +			      struct mm_struct *mm, gfp_t gfp_mask)

s/mem_cgroup_newpage_charge/mem_cgroup_anon_charge/ ?

Would be a better name? The patch would be bigger but the name more
apparent...

Other than that I am good with this. Without (preferably) or without
rename:
Acked-by: Michal Hocko <mhocko@suse.cz>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
