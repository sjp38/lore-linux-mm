Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE3718E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 13:33:56 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g13so2028666plo.10
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:33:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3sor27042051plg.12.2019.01.23.10.33.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 10:33:55 -0800 (PST)
Date: Wed, 23 Jan 2019 11:33:53 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 1/6] mm: make mm->pinned_vm an atomic64 counter
Message-ID: <20190123183353.GA15768@ziepe.ca>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-2-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121174220.10583-2-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Christoph Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Mon, Jan 21, 2019 at 09:42:15AM -0800, Davidlohr Bueso wrote:
> Taking a sleeping lock to _only_ increment a variable is quite the
> overkill, and pretty much all users do this. Furthermore, some drivers
> (ie: infiniband and scif) that need pinned semantics can go to quite
> some trouble to actually delay via workqueue (un)accounting for pinned
> pages when not possible to acquire it.
> 
> By making the counter atomic we no longer need to hold the mmap_sem
> and can simply some code around it for pinned_vm users. The counter
> is 64-bit such that we need not worry about overflows such as rdma
> user input controlled from userspace.

I see a number of MM people Reviewed-by this so are we good to take
this in the RDMA tree now?

Regards,
Jason
