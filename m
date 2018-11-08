Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFC026B0597
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 03:01:47 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id n22-v6so17676271pff.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 00:01:47 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33-v6si3080043pgv.588.2018.11.08.00.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 00:01:47 -0800 (PST)
Date: Thu, 8 Nov 2018 09:01:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/5] mm, memory_hotplug: print reason for the
 offlining failure
Message-ID: <20181108080145.GM27423@dhcp22.suse.cz>
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-5-mhocko@kernel.org>
 <20181107140413.2c0061e440123be76bf419bf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181107140413.2c0061e440123be76bf419bf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 07-11-18 14:04:13, Andrew Morton wrote:
[...]
> Fix:
> 
> --- a/mm/memory_hotplug.c~mm-memory_hotplug-print-reason-for-the-offlining-failure-fix
> +++ a/mm/memory_hotplug.c
> @@ -1576,7 +1576,7 @@ static int __ref __offline_pages(unsigne
>  				       MIGRATE_MOVABLE, true);
>  	if (ret) {
>  		mem_hotplug_done();
> -		reason = "failed to isolate range";
> +		reason = "failure to isolate range";
>  		goto failed_removal
>  	}
>  
> @@ -1587,7 +1587,7 @@ static int __ref __offline_pages(unsigne
>  	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
>  	ret = notifier_to_errno(ret);
>  	if (ret) {
> -		reason = "notifiers failure";
> +		reason = "notifier failure";
>  		goto failed_removal_isolated;
>  	}
>  
> @@ -1616,7 +1616,7 @@ repeat:
>  	 */
>  	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
>  	if (ret) {
> -		reason = "fails to disolve hugetlb pages";
> +		reason = "failure to dissolve huge pages";
>  		goto failed_removal_isolated;
>  	}
>  	/* check again */
> _
> 

LGTM, thanks!

-- 
Michal Hocko
SUSE Labs
