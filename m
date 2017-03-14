Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29B206B038A
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 03:37:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q126so360013027pga.0
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 00:37:35 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k72si13914768pge.101.2017.03.14.00.37.33
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 00:37:34 -0700 (PDT)
Date: Tue, 14 Mar 2017 16:37:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 09/10] mm: make rmap_one boolean function
Message-ID: <20170314073732.GB29720@bbox>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
 <1489365353-28205-10-git-send-email-minchan@kernel.org>
 <20170313124500.ffc91fa4d4077719928e3274@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313124500.ffc91fa4d4077719928e3274@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

Hi Andrew,

On Mon, Mar 13, 2017 at 12:45:00PM -0700, Andrew Morton wrote:
> On Mon, 13 Mar 2017 09:35:52 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > rmap_one's return value controls whether rmap_work should contine to
> > scan other ptes or not so it's target for changing to boolean.
> > Return true if the scan should be continued. Otherwise, return false
> > to stop the scanning.
> > 
> > This patch makes rmap_one's return value to boolean.
> 
> "SWAP_AGAIN" conveys meaning to the reader, whereas the meaning of
> "true" is unclear.  So it would be better to document the return value
> of these functions.

Fair enough.
I will add description like this.

        /*
         * Return false if page table scanning in rmap_walk should be stopped.
         * Otherwise, return true.
         */
        bool (*rmap_one)(struct page *page, struct vm_area_struct *vma,
                                        unsigned long addr, void *arg);


I will wait by noon tomorrow and if there are no further comment,
I will resend v2.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
