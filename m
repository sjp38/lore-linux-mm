Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 629DC6B03A3
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 02:12:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q19so8100298wra.6
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:12:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u190si10520981wmf.146.2017.03.29.23.12.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 23:12:50 -0700 (PDT)
Date: Thu, 30 Mar 2017 08:12:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170330061245.GA1972@dhcp22.suse.cz>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
 <20170328165513.GC27446@linux-80c1.suse>
 <20170328175408.GD7838@bombadil.infradead.org>
 <20170329080625.GC27994@dhcp22.suse.cz>
 <20170329174514.GB4543@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329174514.GB4543@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

On Wed 29-03-17 10:45:14, Andi Kleen wrote:
> On Wed, Mar 29, 2017 at 10:06:25AM +0200, Michal Hocko wrote:
> > On Tue 28-03-17 10:54:08, Matthew Wilcox wrote:
> > > On Tue, Mar 28, 2017 at 09:55:13AM -0700, Davidlohr Bueso wrote:
> > > > Do we have any consensus here? Keeping SHM_HUGE_* is currently
> > > > winning 2-1. If there are in fact users out there computing the
> > > > value manually, then I am ok with keeping it and properly exporting
> > > > it. Michal?
> > > 
> > > Well, let's see what it looks like to do that.  I went down the rabbit
> > > hole trying to understand why some of the SHM_ flags had the same value
> > > as each other until I realised some of them were internal flags, some
> > > were flags to shmat() and others were flags to shmget().  Hopefully I
> > > disambiguated them nicely in this patch.  I also added 8MB and 16GB sizes.
> > > Any more architectures with a pet favourite huge/giant page size we
> > > should add convenience defines for?
> > 
> > Do we actually have any users?
> 
> Yes this feature is widely used.

Considering that none of SHM_HUGE* has been exported to the userspace
headers all the users would have to use the this flag by the value and I
am quite skeptical that application actually do that. Could you point me
to some projects that use this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
