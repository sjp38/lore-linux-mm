Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93CC78E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:03:33 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so15518184pgd.0
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 19:03:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor25861026pll.40.2018.12.18.19.03.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 19:03:32 -0800 (PST)
Date: Tue, 18 Dec 2018 20:03:29 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181219030329.GI21992@ziepe.ca>
References: <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181218103306.GC18032@quack2.suse.cz>
 <20181218234254.GC31274@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218234254.GC31274@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 19, 2018 at 10:42:54AM +1100, Dave Chinner wrote:

> Essentially, what we are talking about is how to handle broken
> hardware. I say we should just brun it with napalm and thermite
> (i.e. taint the kernel with "unsupportable hardware") and force
> wait_for_stable_page() to trigger when there are GUP mappings if
> the underlying storage doesn't already require it.

If you want to ban O_DIRECT/etc from writing to file backed pages,
then just do it.

Otherwise I'm not sure demanding some unrealistic HW design is
reasonable. ie nvme drives are not likely to add page faulting to
their IO path any time soon.

A SW architecture that relies on page faulting is just not going to
support real world block IO devices.

GPUs and one RDMA are about the only things that can do this today,
and they are basically irrelevant to O_DIRECT.

Jason
