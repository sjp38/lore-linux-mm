Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 99A776B0099
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 14:36:58 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so10652792pdj.38
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 11:36:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qo10si24573831pac.133.2014.09.09.11.36.57
        for <linux-mm@kvack.org>;
        Tue, 09 Sep 2014 11:36:57 -0700 (PDT)
Message-ID: <540F48BA.2090304@intel.com>
Date: Tue, 09 Sep 2014 11:36:42 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a
 node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com> <540F20AB.4000404@plexistor.com>
In-Reply-To: <540F20AB.4000404@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 09/09/2014 08:45 AM, Boaz Harrosh wrote:
> This is for add_persistent_memory that will want a section of pages
> allocated but without any zone associated. This is because belonging
> to a zone will give the memory to the page allocators, but
> persistent_memory belongs to a block device, and is not available for
> regular volatile usage.

I don't think we should be taking patches like this in to the kernel
until we've seen the other side of it.  Where is the page allocator code
which will see a page belonging to no zone?  Am I missing it in this set?

I see about 80 or so calls to page_zone() in the kernel.  How will a
zone-less page look to all of these sites?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
