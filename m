Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8CBD6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:33:46 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id f198so79047154wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 08:33:46 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id ck9si3783126wjc.88.2016.04.06.08.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 08:33:45 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id u206so51110844wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 08:33:45 -0700 (PDT)
Date: Wed, 6 Apr 2016 17:33:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: PG_reserved and compound pages
Message-ID: <20160406153343.GJ24272@dhcp22.suse.cz>
References: <4482994.u2S3pScRyb@noys2>
 <20160406150206.GB24283@dhcp22.suse.cz>
 <3877205.TjDYue2aah@noys2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3877205.TjDYue2aah@noys2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 06-04-16 17:12:43, Frank Mehnert wrote:
> Hi Michal,
> 
> On Wednesday 06 April 2016 17:02:06 Michal Hocko wrote:
> > [CCing linux-mm mailing list]
> > 
> > On Wed 06-04-16 13:28:37, Frank Mehnert wrote:
> > > Hi,
> > > 
> > > Linux 4.5 introduced additional checks to ensure that compound pages are
> > > never marked as reserved. In our code we use PG_reserved to ensure that
> > > the kernel does never swap out such pages, e.g.
> > 
> > Are you putting your pages on the LRU list? If not how they could get
> > swapped out?
> 
> No, we do nothing like that. It was my understanding that at least with
> older kernels it was possible that pages allocated with alloc_pages()
> could be swapped out or otherwise manipulated, I might be wrong.

I do not see anything like that. All the evictable pages should be on
a LRU.

> For
> instance, it's also necessary that the physical address of the page
> is known and that it does never change. I know, there might be problems
> with automatic NUMA page migration but that's another story.

Do you map your pages to the userspace? If yes then vma with VM_IO or
VM_PFNMAP should keep any attempt away from those pages.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
