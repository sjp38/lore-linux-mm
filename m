Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05E716B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:58:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e5so74046332pgk.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:57:59 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id f16si4249744pli.29.2017.03.15.22.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 22:57:59 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id v190so4579172pfb.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:57:59 -0700 (PDT)
Date: Thu, 16 Mar 2017 14:57:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 10/10] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
Message-ID: <20170316055754.GB464@jagdpanzerIV.localdomain>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
 <1489555493-14659-11-git-send-email-minchan@kernel.org>
 <20170316044023.GA2597@jagdpanzerIV.localdomain>
 <20170316053313.GA19241@bbox>
 <20170316054430.GA464@jagdpanzerIV.localdomain>
 <20170316055154.GA26126@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316055154.GA26126@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On (03/16/17 14:51), Minchan Kim wrote:
[..]
> > > @@ -1414,7 +1414,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > >  			 */
> > >  			if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
> > >  				WARN_ON_ONCE(1);
> > > -				ret = SWAP_FAIL;
> > > +				ret = false;
> > >  				page_vma_mapped_walk_done(&pvmw);
> > >  				break;
> > >  			}
> > 
> > 
> > one thing to notice here is that 'ret = false' and 'ret = SWAP_FAIL'
> > are not the same and must produce different results. `ret' is bool
> > and SWAP_FAIL was 2. it's return 1 vs return 0, isn't it? so was
> > there a bug before?
> 
> No, it was not a bug. Just my patchset changed return value meaning.
> Look at this.
> https://marc.info/?l=linux-mm&m=148955552314806&w=2
> 
> So, false means SWAP_FAIL(ie., stop rmap scanning and bail out) now.

ah, indeed. sorry, didn't notice that.

thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
