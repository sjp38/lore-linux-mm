Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7FE36B000A
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 20:27:27 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t19-v6so5841543plo.9
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 17:27:27 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f11-v6si464659pgk.403.2018.07.19.17.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 17:27:26 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v3 1/8] swap: Add comments to lock_cluster_or_swap_info()
References: <20180719084842.11385-1-ying.huang@intel.com>
	<20180719084842.11385-2-ying.huang@intel.com>
	<20180719123908.GA28522@infradead.org>
Date: Fri, 20 Jul 2018 08:27:22 +0800
In-Reply-To: <20180719123908.GA28522@infradead.org> (Christoph Hellwig's
	message of "Thu, 19 Jul 2018 05:39:08 -0700")
Message-ID: <87wotqvjit.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

Christoph Hellwig <hch@infradead.org> writes:

> On Thu, Jul 19, 2018 at 04:48:35PM +0800, Huang Ying wrote:
>> +/*
>> + * Determine the locking method in use for this device.  Return
>> + * swap_cluster_info if SSD-style cluster-based locking is in place.
>> + */
>>  static inline struct swap_cluster_info *lock_cluster_or_swap_info(
>>  	struct swap_info_struct *si,
>>  	unsigned long offset)
>>  {
>>  	struct swap_cluster_info *ci;
>>  
>> +	/* Try to use fine-grained SSD-style locking if available: */
>
> Once you touch this are can you also please use standard two-tab
> alignment for the spill-over function arguments:
>
> static inline struct swap_cluster_info *lock_cluster_or_swap_info(
> 		struct swap_info_struct *si, unsigned long offset)

Sure.  Will change this in next version.

Best Regards,
Huang, Ying
