Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C21828E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 13:45:32 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s19so6624173qke.20
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 10:45:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c5si4191940qth.210.2018.12.08.10.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Dec 2018 10:45:32 -0800 (PST)
Date: Sat, 8 Dec 2018 13:45:26 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181208184525.GC2952@redhat.com>
References: <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <CAPcyv4hwtMA+4qc6500ucn5vf6fRrNdfyMHru_Jhzx86=1Wwww@mail.gmail.com>
 <20181208163353.GA2952@redhat.com>
 <20181208164825.GA26154@infradead.org>
 <20181208174730.GB2952@redhat.com>
 <20181208182604.GA24564@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181208182604.GA24564@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sat, Dec 08, 2018 at 10:26:04AM -0800, Christoph Hellwig wrote:
> On Sat, Dec 08, 2018 at 12:47:30PM -0500, Jerome Glisse wrote:
> > Most of the user of GUP are well behave (everything under driver/gpu and
> > so is mellanox driver and many other) ie they abide by mmu notifier
> > invalidation call backs. They are a handfull of device driver that thought
> > they could just do GUP and ignore the mmu notifier part and those are the
> > one being problematic. So to me it feels like bystander are be shot for no
> > good reasons.
> 
> get_user_pages is used by every single direct I/O, and while the race
> windows in that case are small they very much exists.

Yes and my proposal allow to fix that in even a better way than
the pin count would ie allowing to provide a callback for write
back to wait on direct I/O as you said for direct I/O it is a
small window so it would be fine to have write back wait on it.

Cheers,
J�r�me
