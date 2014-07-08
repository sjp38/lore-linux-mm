Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id CD45A6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 16:41:39 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id r10so1118147igi.10
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:41:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cf10si33268699icc.76.2014.07.08.13.41.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 13:41:38 -0700 (PDT)
Date: Tue, 8 Jul 2014 13:41:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: update the description for vm_total_pages
Message-Id: <20140708134136.597fbd11309d1e376eeb241c@linux-foundation.org>
In-Reply-To: <53BB8553.10508@gmail.com>
References: <53BB8553.10508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org

On Tue, 08 Jul 2014 13:44:51 +0800 Wang Sheng-Hui <shhuiw@gmail.com> wrote:

> 
> vm_total_pages is calculated by nr_free_pagecache_pages(), which counts
> the number of pages which are beyond the high watermark within all zones.
> So vm_total_pages is not equal to total number of pages which the VM controls.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -136,7 +136,11 @@ struct scan_control {
>   * From 0 .. 100.  Higher means more swappy.
>   */
>  int vm_swappiness = 60;
> -unsigned long vm_total_pages;  /* The total number of pages which the VM controls */
> +/*
> + * The total number of pages which are beyond the high watermark
> + * within all zones.
> + */
> +unsigned long vm_total_pages;
> 
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);

Nice patch!  It's good to document these little things as one discovers
them.

However vm_total_pages is only ever used in build_all_zonelists() and
could be made a local within that function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
