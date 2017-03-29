Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21E076B03A0
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:06:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q19so1366967wra.6
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:06:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si6223531wmg.155.2017.03.29.01.06.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 01:06:30 -0700 (PDT)
Date: Wed, 29 Mar 2017 10:06:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170329080625.GC27994@dhcp22.suse.cz>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
 <20170328165513.GC27446@linux-80c1.suse>
 <20170328175408.GD7838@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328175408.GD7838@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

On Tue 28-03-17 10:54:08, Matthew Wilcox wrote:
> On Tue, Mar 28, 2017 at 09:55:13AM -0700, Davidlohr Bueso wrote:
> > Do we have any consensus here? Keeping SHM_HUGE_* is currently
> > winning 2-1. If there are in fact users out there computing the
> > value manually, then I am ok with keeping it and properly exporting
> > it. Michal?
> 
> Well, let's see what it looks like to do that.  I went down the rabbit
> hole trying to understand why some of the SHM_ flags had the same value
> as each other until I realised some of them were internal flags, some
> were flags to shmat() and others were flags to shmget().  Hopefully I
> disambiguated them nicely in this patch.  I also added 8MB and 16GB sizes.
> Any more architectures with a pet favourite huge/giant page size we
> should add convenience defines for?

Do we actually have any users?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
