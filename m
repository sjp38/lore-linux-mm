Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 14E306B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:02:10 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id v188so26317952wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 08:02:10 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id ws8si3668336wjc.16.2016.04.06.08.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 08:02:08 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id f198so77685114wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 08:02:08 -0700 (PDT)
Date: Wed, 6 Apr 2016 17:02:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PG_reserved and compound pages
Message-ID: <20160406150206.GB24283@dhcp22.suse.cz>
References: <4482994.u2S3pScRyb@noys2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4482994.u2S3pScRyb@noys2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

[CCing linux-mm mailing list]

On Wed 06-04-16 13:28:37, Frank Mehnert wrote:
> Hi,
> 
> Linux 4.5 introduced additional checks to ensure that compound pages are
> never marked as reserved. In our code we use PG_reserved to ensure that
> the kernel does never swap out such pages, e.g.

Are you putting your pages on the LRU list? If not how they could get
swapped out?

> 
>   int i;
>   struct page *pages = alloc_pages(GFP_HIGHUSER | __GFP_COMP, 4);
>   for (i = 0; i < 16; i++)
>     SetPageReserved(&pages[i]);
> 
> The purpose of setting PG_reserved is to prevent the kernel from swapping
> this memory out. This worked with older kernel but not with Linux 4.5 as
> setting PG_reserved to compound pages is not allowed any more.
> 
> Can somebody explain how we can achieve the same result in accordance to
> the new Linux 4.5 rules?
> 
> Thanks,
> 
> Frank
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
