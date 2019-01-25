Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 515828E00C8
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 09:30:47 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f17so3769270edm.20
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 06:30:47 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si15382341edd.269.2019.01.25.06.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 06:30:46 -0800 (PST)
Date: Fri, 25 Jan 2019 15:30:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 2/3] mm: Move buddy list manipulations into helpers
Message-ID: <20190125143044.GO3560@dhcp22.suse.cz>
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327612.676627.7469591833063917773.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154690327612.676627.7469591833063917773.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Dave Hansen <dave.hansen@linux.intel.com>, keith.busch@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

On Mon 07-01-19 15:21:16, Dan Williams wrote:
> In preparation for runtime randomization of the zone lists, take all
> (well, most of) the list_*() functions in the buddy allocator and put
> them in helper functions. Provide a common control point for injecting
> additional behavior when freeing pages.

Looks good in general and it actually makes the code more readable.
One nit below

[...]
> +static inline void rmv_page_order(struct page *page)
> +{
> +	__ClearPageBuddy(page);
> +	set_page_private(page, 0);
> +}
> +

I guess we do not really need this helper and simply squash it to its
only user.

Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs
