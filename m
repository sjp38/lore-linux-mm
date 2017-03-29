Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51B0D6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 13:45:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v21so13942027pgo.22
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:45:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r80si5974828pfr.55.2017.03.29.10.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 10:45:24 -0700 (PDT)
Date: Wed, 29 Mar 2017 10:45:14 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170329174514.GB4543@tassilo.jf.intel.com>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
 <20170328165513.GC27446@linux-80c1.suse>
 <20170328175408.GD7838@bombadil.infradead.org>
 <20170329080625.GC27994@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329080625.GC27994@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

On Wed, Mar 29, 2017 at 10:06:25AM +0200, Michal Hocko wrote:
> On Tue 28-03-17 10:54:08, Matthew Wilcox wrote:
> > On Tue, Mar 28, 2017 at 09:55:13AM -0700, Davidlohr Bueso wrote:
> > > Do we have any consensus here? Keeping SHM_HUGE_* is currently
> > > winning 2-1. If there are in fact users out there computing the
> > > value manually, then I am ok with keeping it and properly exporting
> > > it. Michal?
> > 
> > Well, let's see what it looks like to do that.  I went down the rabbit
> > hole trying to understand why some of the SHM_ flags had the same value
> > as each other until I realised some of them were internal flags, some
> > were flags to shmat() and others were flags to shmget().  Hopefully I
> > disambiguated them nicely in this patch.  I also added 8MB and 16GB sizes.
> > Any more architectures with a pet favourite huge/giant page size we
> > should add convenience defines for?
> 
> Do we actually have any users?

Yes this feature is widely used.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
